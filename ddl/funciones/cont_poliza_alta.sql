CREATE OR REPLACE FUNCTION keplersc.cont_poliza_alta(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables para xml 
	sucursal_id text;
	sucursal_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	grupo_docto text='';
	tipo_poliza text = '';
	tipo_poliza_desc text= '';
	no_partidas int = 0;
	total_cargos decimal = 0.00;
	total_abonos decimal = 0.00;
	docto text = '';
	fecha_operacion text; --yyyy-mm-dd
	usuario_movto text;
	fecha_movto text;
	hora_movto text; 
	referencia text;
	anio text ='';
	mes text = '';

	--variables kdc
	cuenta_kdc text;
	monto_cargo decimal = 0.00;
	monto_abono decimal = 0.00;
	tipo_asiento_kdc text = '';
	accion_poliza_kdc text = '';
	folio_poliza_kdc int = 0;
	numero_partida_poliza_kdc int = 0;
	descripcion_partida text = '';
	monto_partida decimal = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	mensajeError text;
	varcont xml;
	expSql text='';
	folio_id text = '';
	total_registros int = 0;
	transaccion_id text = '';
	totalreg int =0;
	xmlKDMM xml;
	paso text='';
	folio_operacion text = '';
	params text  ='';
	xmlKdm1 xml;
	tmpInt int = 0;
	xmlResultado xml;
	xmlUsr xml;

begin
	--Trasaccion
	sucursal_desc := (xpath('//document/k_sucn/r2/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];	
	genero := (xpath('//document/tipopoliza/r2/text()', dataxml))[1];
	naturaleza := (xpath('//document/tipopoliza/r3/text()', dataxml))[1];
	grupo := (xpath('//document/tipopoliza/r4/text()', dataxml))[1];
	tipo := (xpath('//document/tipopoliza/r5/text()', dataxml))[1];
	docto := (xpath('//document/k_docto/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1];
	anio := (xpath('//document/anio/text()',dataxml))[1];
	mes := (xpath('//document/mes/text()',dataxml))[1];
	grupo_docto := (xpath('//document/grpDoc/r0/text()',dataxml))[1];
	tipo_poliza := (xpath('//document/k_tipo/text()',dataxml))[1];
	tipo_poliza_desc := (xpath('//document/grpDoc/r0/text()', dataxml))[1];
	accion_poliza_kdc := (xpath('//document/operacion/text()', dataxml))[1];

	strValor := coalesce((xpath('//document/k_poliza/no_partidas/text()', dataxml))[1]::text,'0');
	no_partidas=strValor::int;
	strValor := coalesce((xpath('//document/totalCargos/text()', dataxml))[1]::text,'0');
	total_cargos := strValor::decimal;
	strValor := coalesce((xpath('//document/totalAbonos/text()', dataxml))[1]::text,'0');
	total_abonos := strValor::decimal;	
	--Movimiento
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	--Validar que se tengan partidas
	if no_partidas=0 then
		raise exception 'No se tienen movimientos en la póliza.';
	end if;

	--Validar que se traigan cargos y abonos y que la poliza este cuadrada.
	if total_cargos=0 or total_abonos = 0 then 
		raise exception 'No se tienen movimientos suficientes en la póliza.';		
	end if;

	if (total_cargos - total_abonos) <> 0 then 
		raise exception 'La póliza está descuadrada.';		
	end if;

	--Obtener identificador de la transaccion
	transaccion_id := keplersc.log_tran_id_gen(); --Obtiene identificador de la transaccion

	--Registro de INICIO de transaccion en bitacora
	call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, true, dataxml::text,'INFO',
		xmlResultado);	
	
/*
 * Validaciones genéricas del documento y obtencion del xml del documento
 */
	if genero is null or (genero<>'X' and genero<>'U' and genero<>'N') then
		mensajeError := 'Genero de documento no definido';
		raise exception '%: %',mensajeError,genero;
	end if;

	if naturaleza is null or (naturaleza<>'D' and naturaleza<>'A' and naturaleza<>'N') then
		mensajeError := 'Naturaleza de documento no definida';
		raise exception '%: %',mensajeError,naturaleza;
	end if;

	totalReg := 0;

    select count(*) into totalReg from keplersc.kdmm where c1=genero and c2=naturaleza and c3=grupo::int and c4=tipo::int;

	if totalReg = 0 then
		mensajeError := 'Documento no definido en BD';
		raise exception '%',mensajeError;			
	end if;

	expSql = 'select * from keplersc.kdmm where c1='  || E'\'' || genero || E'\'' ||
	' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;
	
	select query_to_xml(expSql, true, false, '') into xmlKDMM;
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	if strValor is not null then
		if strValor = 'S' then
			mensajeError := 'Documento no válido';
			raise exception '%',mensajeError;			
		end if;
	end if;	
		
	--Obtener folio de la transaccion
	folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento
	paso := 'cont_poliza_alta.obtener_folio_documento';
	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_documento(folio_id,0,0,dataxml);
	if resultado = '0' then	
		raise exception '%',mensaje;
	end if;
	folio_operacion := mensaje;

	--Creacion de xml para insercion en kdm1
	strValor := concat(strValor,format('<k_sucn>'));
	strValor := concat(strValor,format('<r0>%1$s</r0>',sucursal_desc));
	strValor := concat(strValor,format('<r1>%1$s</r1>',sucursal_id));
	strValor := concat(strValor,format('</k_sucn>'));

	strValor := concat(strValor,format('<k_tipon>'));
	strValor := concat(strValor,format('<r0>%1$s</r0>',tipo_poliza));
	strValor := concat(strValor,format('<r1>%1$s</r1>',genero));
	strValor := concat(strValor,format('<r2>%1$s</r2>',naturaleza));
	strValor := concat(strValor,format('<r3>%1$s</r3>',grupo));
	strValor := concat(strValor,format('<r4>%1$s</r4>',tipo));
	strValor := concat(strValor,format('<r5>%1$s</r5>',docto));
	strValor := concat(strValor,format('</k_tipon>'));
	strValor := concat(strValor,format('<k_fecha>%1$s</k_fecha>',fecha_operacion));
	strValor := concat(strValor,format('<k_clave>%1$s</k_clave>',0)); --Clave del cliente/proveedor
	strValor := concat(strValor,format('<k_refer>%1$s</k_refer>',referencia));
	strValor := concat(strValor,format('<k_tipon>%1$s</k_tipon>',concat(tipo_poliza_desc, ' ', tipo_poliza))); --Clave del cliente/proveedor
	strValor := concat(strValor,format('<k_foliodocto>%1$s</k_foliodocto>','0000001'));
	strValor := concat(strValor,format('<no_partidas>%1$s</no_partidas>',no_partidas));

	strValor := concat(strValor,format('<movimiento>'));
	strValor := concat(strValor,format('<usuario>%1$s</usuario>',usuario_movto));
	strValor := concat(strValor,format('<fecha>%1$s</fecha>',fecha_movto));
	strValor := concat(strValor,format('<hora>%1$s</hora>',hora_movto));
	strValor := concat(strValor,format('</movimiento>'));

	--strValor := format('<document>%1$s</document>',strValor);	  
	xmlKdm1 := format('<document>%1$s</document>',strValor)::xml;  
	--xmlKdm1 := strValor::xml;

	--Insercion en kdm1
	paso:= 'cont_poliza_alta.mov_prim_alta';
	select * into resultado, mensaje, adicionales from keplersc.mov_prim_alta(xmlKdm1, folio_operacion);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	


-- Insercion de poliza para cada uno de los movimientos
	folio_id := 'POLIZA' || tipo_poliza || substring(fecha_operacion, 3, 2) || substring(fecha_operacion, 6, 2);

	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_id);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza_kdc := mensaje::int;

	numero_partida_poliza_kdc = 0;
	for cont in 0..no_partidas loop
		cuenta_kdc:= (xpath('//document/k_poliza/r' || cont || '/k_cuenta/text()',dataxml))[1];
		strValor := coalesce((xpath('//document/k_poliza/r' || cont || '/k_cargo/text()',dataxml))[1],'0');
		monto_cargo := strValor::decimal;	
		strValor := coalesce((xpath('//document/k_poliza/r' || cont || '/k_abono/text()',dataxml))[1],'0');
		monto_abono := strValor::decimal;
		descripcion_partida := coalesce((xpath('//document/k_poliza/r' || cont || '/k_descr/text()',dataxml))[1],'0');

		--Validar partida
		if monto_cargo <> 0 and monto_abono <> 0 then
			raise exception 'Una misma partida no puede tener importe en cargo y abono.';
		end if;
	
		if monto_cargo =0 and monto_abono = 0 then --Es posible que se trate del ultimo regitro de la tabla.
			continue;
		end if;

		--Validar que cuenta sea de ultimo nivel
		select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(cuenta_kdc,anio);
	
		if resultado='0' then --Cuenta no es de mas bajo nivel
			raise exception '%',mensaje;
		end if;	
	
		--Validar que cuenta no esté en gastos
		select * into resultado, mensaje, adicionales from keplersc.verify_gastos(cuenta_kdc);
	
		if resultado='0' then --Cuenta tiene gastos
			raise exception '%', mensaje;
		end if;		
	
		if monto_cargo > 0 then
			tipo_asiento_kdc = 'C';
			monto_partida = monto_cargo;
		else
			tipo_asiento_kdc = 'A';
			monto_partida = monto_abono;
		end if;		
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		select xmlforest(fecha_operacion as fecha, cuenta_kdc as cuenta, tipo_asiento_kdc as tipo_asiento, 
		   monto_partida as monto,descripcion_partida as descrip, referencia as refer, 
		   tipo_poliza as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
		   sucursal_id as sucursal, genero, naturaleza, grupo, tipo as tipo_clave, folio_operacion,
		   accion_poliza_kdc as accion_poliza,folio_poliza_kdc as folio_poliza,
		   numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
	
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	end loop;

/*
 * REGISTRO DE OPERACION EN BITACORA DE USUARIOS PARA TRANSACCIONES SATISFACTORIAS
 */
	if resultado='1' then
		select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
		   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
		   'ALTAPOLIZA' as tipo_movto) :: text into strValor;
	
		select '<document>'||strValor||'</document>' into strValor;
		xmlUsr := strValor::xml;
	
		select * into resultado, mensaje, adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;	
	end if;
/*
 * FIN REGISTRO DE OPERACION EN BITACORA DE USUARIOS
 */
	resultado := 1;
	mensaje := concat('Folio operación: ',folio_operacion, '; póliza: ',folio_poliza_kdc);
	adicionales := '';

	return query select resultado, mensaje, adicionales;	

exception
	when others then
		xmlResultado := '';
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, false, SQLERRM, 'ERR', xmlResultado);	
		resultado := 0;
		mensaje := 'cont_poliza_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
