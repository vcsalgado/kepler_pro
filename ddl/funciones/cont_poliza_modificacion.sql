CREATE OR REPLACE FUNCTION keplersc.cont_poliza_modificacion(dataxml xml)
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
	intValor int;
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
	tabla_cuentas text = '';

	_poliza int = 0;
	_cuenta text = '';
	_cargo_abono text = '';
	_monto decimal = 0.00;
	campo_cuentas text;
	campo_base_pesos_cargos_kdc1 int = 27;
	campo_base_pesos_abonos_kdc1 int = 63;

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

	folio_operacion = split_part(docto, '-', 2); 

	--Obtener identificador de la transaccion
	transaccion_id := keplersc.log_tran_id_gen(); --Obtiene identificador de la transaccion
	
	--Validar que se tengan partidas
	if no_partidas=0 then
		raise exception 'No se tienen movimientos en la póliza.';
	end if;

	--cuentas
	tabla_cuentas := 'keplersc.kdc1' || anio;
	intValor := mes::int;

	tabla_kdc2 := concat('kdc2',lpad(anio,2,'0'),lpad(mes,2,'0')) ;
	strValor:='';

	_poliza:=folio_poliza_kdc;


/* VCSS Los saldos de las cuentas en kdc1 se actualizan por medio de triggers desde cada tabla kdc2
 * por lo que las siguientes lineas se eliminan
	--Crear tabla temporal del cuentas para poliza
	drop table if exists auxPoliza;
	create temp table auxPoliza(
		poliza int,
		cuenta varchar(20),
		cargo_abono varchar(1),
		monto numeric(15,2) default 0
	);


	expSql=concat('insert into auxPoliza select c1 as poliza, c3 as cuenta, 
		c4 as cargo_abono, c5 as monto 
		from keplersc.',tabla_kdc2,' where c1=',folio_poliza_kdc, ' and c8=''', tipo_poliza,'''');
	execute expSql;

	for _poliza, _cuenta, _cargo_abono, _monto in 
		select poliza, cuenta, cargo_abono, monto from auxPoliza  
	loop
		intValor := mes::int;
		--Actualizar saldos disminuyendo el importe de cada partida
		if _cargo_abono = 'C' then --Cargo
			intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
			campo_cuentas := intValor::text;
		else
			intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
			campo_cuentas := intValor::text;
		end if;

		expSql=format('update %1$s set c%2$s = c%2$s - %3$s where position(c1 in %4$L) = 1
			returning 1::text ',tabla_cuentas, campo_cuentas, _monto, _cuenta);
	
		execute expSql into strValor;

		if strValor is null then
			raise exception 'No se acumularon saldos en las cuentas %.',cuenta ;
		end if;
	
		raise notice '%', _cuenta;
	end loop;
*/

	--Eliminar las partidas de la poliza
	expSql=format('delete from keplersc.%1$s where c1 = %2$s and c8=%3$L',tabla_kdc2, _poliza,tipo_poliza);

	execute expSql;
	--Insertar nuevas partidas
	for cont in 0..no_partidas loop
		cuenta_kdc:= (xpath('//document/k_poliza/r' || cont || '/k_cuenta/text()',dataxml))[1];
		strValor := coalesce((xpath('//document/k_poliza/r' || cont || '/k_cargo/text()',dataxml))[1],'0');
		monto_cargo := strValor::decimal;	
		strValor := coalesce((xpath('//document/k_poliza/r' || cont || '/k_abono/text()',dataxml))[1],'0');
		monto_abono := strValor::decimal;
		descripcion_partida := coalesce((xpath('//document/k_poliza/r' || cont || '/k_descr/text()',dataxml))[1],'0');
		descripcion_partida:=usuario_movto ||': ' || descripcion_partida; 
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

/*No aplica la validacion de gastos en la modificacion de polizas	
		--Validar que cuenta no esté en gastos
		select * into resultado, mensaje, adicionales from keplersc.verify_gastos(cuenta_kdc);
	
		if resultado='0' then --Cuenta tiene gastos
			raise exception '%', mensaje;
		end if;		
*/	
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

 
	--Registro de INICIO de transaccion en bitacora
	call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, true, dataxml::text,'INFO',
		xmlResultado);	

	--Eliminar partidas de poliza actual, disminuir cargos o abonos en kdc1 y eliminar el registros en kdc2

	

/*
 * REGISTRO DE OPERACION EN BITACORA DE USUARIOS PARA TRANSACCIONES SATISFACTORIAS
 */
	if resultado='1' then
		select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
		   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
		   'MODPOLIZA' as tipo_movto) :: text into strValor;
	
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
--raise exception 'Proceso de prueba finalizado:%',folio_poliza_kdc;
	return query select resultado, mensaje, adicionales;	
 
exception
	when others then
	raise notice 'Mensaje: %',SQLERRM;
		xmlResultado := '';
		mensaje := 'cont_poliza_modificacion() ' || '['|| sqlstate || '] ' || sqlerrm;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, false, SQLERRM, 'ERR', xmlResultado);	
		resultado := 0;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
