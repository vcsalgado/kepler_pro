CREATE OR REPLACE FUNCTION keplersc.cont_poliza_baja(dataxml xml)
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
	paso text='';
	folio_operacion text = '';
	params text  ='';
	tmpInt int = 0;
	xmlResultado xml;
	xmlUsr xml;
	tabla_kdc2 text = '';

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
	folio_poliza_kdc := (xpath('//document/k_npoliza/text()', dataxml))[1];

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

	--Obtener identificador de la transaccion
	transaccion_id := keplersc.log_tran_id_gen(); --Obtiene identificador de la transaccion
	
	--Validar que se tengan partidas
	if no_partidas=0 then
		raise exception 'No se tienen movimientos en la póliza.';
	end if;

	--Registro de INICIO de transaccion en bitacora
	call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, true, dataxml::text,'INFO',
		xmlResultado);	

	--Obtener el numero mayor de partida registrado en la poliza
	tabla_kdc2 := concat('kdc2',lpad(anio,2,'0'),lpad(mes,2,'0')) ;
	expSql:=format('select max(c10) from keplersc.%1$s where c1=%2$s and c14=%3$L and c15=%4$L and c16=%5$L and c17=%6$s and c18=%7$s ',
		tabla_kdc2,folio_poliza_kdc,sucursal_id,genero,naturaleza,grupo,tipo);
	
	execute expSql into numero_partida_poliza_kdc;
	numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;

	folio_operacion = split_part(docto, '-', 2);


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
		
		--Completar descripcion 
		descripcion_partida := concat('BAJA: ', descripcion_partida);
	
	
		--Por tratarse de una baja, se cambian cargos por abonos y viceversa
		if monto_cargo > 0 then
			tipo_asiento_kdc = 'A';
			monto_partida = monto_cargo;
		else
			tipo_asiento_kdc = 'C';
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

	--Cancelar movimiento en kdm1
	update keplersc.kdm1 set c43 = 'C' 
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::numeric and c5=tipo::numeric and c6=folio_operacion;


/*
 * REGISTRO DE OPERACION EN BITACORA DE USUARIOS PARA TRANSACCIONES SATISFACTORIAS
 */
	if resultado='1' then
		select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
		   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
		   'BAJAPOLIZA' as tipo_movto) :: text into strValor;
	
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
	raise notice 'Mensaje: %',SQLERRM;
		xmlResultado := '';
		mensaje := 'cont_poliza_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, false, SQLERRM, 'ERR', xmlResultado);	
		resultado := 0;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
