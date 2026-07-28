CREATE OR REPLACE FUNCTION keplersc.cont_poliza_partida_alta(datacontxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables para xml 
	fecha text = ''; --aaaa-mm-dd
	cuenta text = '';
	tipo_asiento text = '';
	monto decimal = 0.00;
	descrip text = '';
	refer text = '';
	tipo_poliza text = '';
	moneda text = '';
	depto text = '';
	concepto text ='';
	proyecto text = '';
	sucursal text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	folio_operacion text = '';
	accion_poliza text = '';
	folio_poliza text = '';
	numero_partida text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	anio_en_curso text;
	mes_en_curso text;
	tabla_cuentas text = '';
	campo_cuentas text = '';
	tabla_polizas text = '';
	campo_polizas text = '';
	strValor text = '';
	intValor int = 0;
	mensajeError text;
	varcont xml;
	expSql text='';
	campo_base_pesos_cargos_kdc1 int = 27;
	campo_base_pesos_abonos_kdc1 int = 63;
	

begin
	--Obtener valores de xml
	fecha := (xpath('//varcont/fecha/text()',datacontxml))[1]::text;
	cuenta := (xpath('//varcont/cuenta/text()',datacontxml))[1]::text;
	tipo_asiento := (xpath('//varcont/tipo_asiento/text()',datacontxml))[1]::text;
	strValor := (xpath('//varcont/monto/text()',datacontxml))[1]::text;

	monto := strValor::decimal;
	descrip := (xpath('//varcont/descrip/text()',datacontxml))[1]::text;
	refer := coalesce((xpath('//varcont/refer/text()',datacontxml))[1],'');

	tipo_poliza := (xpath('//varcont/tipo_poliza/text()',datacontxml))[1]::text;
	moneda := (xpath('//varcont/moneda/text()',datacontxml))[1]::text;
	depto := (xpath('//varcont/depto/text()',datacontxml))[1]::text;
	concepto := (xpath('//varcont/concepto/text()',datacontxml))[1]::text;
	proyecto := (xpath('//varcont/proyecto/text()',datacontxml))[1]::text;
	sucursal := (xpath('//varcont/sucursal/text()',datacontxml))[1]::text;
	genero := (xpath('//varcont/genero/text()',datacontxml))[1]::text;
	naturaleza := (xpath('//varcont/naturaleza/text()',datacontxml))[1]::text;
	grupo := (xpath('//varcont/grupo/text()',datacontxml))[1]::text;
	tipo_clave := (xpath('//varcont/tipo_clave/text()',datacontxml))[1]::text;
	folio_operacion := (xpath('//varcont/folio_operacion/text()',datacontxml))[1]::text;
	accion_poliza := (xpath('//varcont/accion_poliza/text()',datacontxml))[1]::text;
	folio_poliza := (xpath('//varcont/folio_poliza/text()',datacontxml))[1]::text;
	numero_partida := (xpath('//varcont/numero_partida/text()',datacontxml))[1]::text;


	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha,3,2);
	mes_en_curso := substring(fecha,6,2);

	--cuentas
	tabla_cuentas := 'keplersc.kdc1' || anio_en_curso;
	intValor := mes_en_curso::int;
	if tipo_asiento = 'C' then --Cargo
		intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
		campo_cuentas := campo_cuentas || intValor::text;
	else
		intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
		campo_cuentas := campo_cuentas || intValor::text;
	end if;

	--Polizas
	tabla_polizas := 'keplersc.kdc2' || anio_en_curso || mes_en_curso;

	--Actualiza cuenta 1.Validar que cuenta existe

	expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta);	
	execute expSql into intValor;
	if intValor = 0 then --La cuenta no existe
		--Validar si la cuenta es de ultimo nivel y no es de perimer nivel
		--Hay niveles arriba 
		expSql = format('select count(*) from %1$s where position(c1 in %2$L) > 0 and substring(c1,1,1) = substring(%2$L,1,1) 
			and c1<>%2$L',tabla_cuentas,cuenta);
		execute expSql into intValor;
--raise exception '1. Sql: %, Valor:%', expSql,intValor;	
		if intValor = 0 then --
			raise exception '%', concat('Imposible agregar la cuenta ', cuenta, ', falta cuenta de primer nivel.');
		end if;	

		--No hay niveles abajo
		expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)
			and c1<>%2$L',tabla_cuentas,cuenta);
		execute expSql into intValor;
--raise exception '2. Sql: %, Valor:%', expSql,intValor;	
		if intValor > 0 then --
			raise exception '%', concat('Imposible agregar la cuenta ', cuenta, ', no es de último nivel.');
		end if ;

		expSql=format('insert into %1$s (c1,c2) values(%2$L,%3$L)',tabla_cuentas,cuenta,substring(descrip,1,40));
		execute expSql;
	end if;

	--Actualiza cuenta 2.Actualizar cuentas

/* VCSS Los saldos de las cuentas en kdc1 se actualizan por medio de triggers desde cada tabla kdc2
	--Acumula saldos de cuenta y padres
	expSql=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
		returning 1::text ',tabla_cuentas, campo_cuentas, monto, cuenta);

	execute expSql into strValor;
--raise notice 'Saldos: %', expSql;
	if strValor is null then
	raise notice 'TABLA: % CAMPO_CUENTA: % MONTO:% CUENTA:%', tabla_cuentas, campo_cuentas, monto, cuenta;
		raise exception 'No se acumularon saldos en las cuentas %.',cuenta ;
	end if;
*/

--	raise notice 'desc: %, refer:%' , descrip, refer;
	--Registra partida poliz
	expSql = format('insert into %1$s (c1,c2,c3,c4,c5,
		c6,c7,c8,c10,c14,
		c15,c16,c17,c18,c19) values(
		%2$L, %3$L, %4$L, %5$L, %6$s, 
		%7$L, %8$L, %9$L, %10$s, %11$L, 
		%12$L, %13$L, %14$s, %15$s, %16$L)',
		tabla_polizas,
		folio_poliza,fecha,cuenta,tipo_asiento,	monto,
		substring(descrip,1,40),refer,tipo_poliza,numero_partida,sucursal,
		genero,naturaleza,grupo,tipo_clave,folio_operacion);
		
--raise notice 'PASO 3 Partida poliza: %', expSql;
	execute expSql;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cont_poliza_partida_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
