CREATE OR REPLACE FUNCTION keplersc.verify_ocompra(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de orden de compra
--Autor: Luis Leal
--Fecha: 23/02/2023
--Bitacora de cambios
	--Variables de definicion de documento
	sucursal_id text = '';
	cargos decimal;
	fecha_operacion text;
	anio_en_curso text;
	mes_en_curso text;
	clave_gasto text;
	desc_gasto text;
	monto_gasto numeric;
	cargos_mes_actual text;
	abonos_mes_actual text;
	total_gastado numeric;
	cargos_total numeric;
	ctd_gastos int;
	sql_gastos text;
	datos_gasto xml;
	usuario_movto text;
	privilegios_admin text;
	
	sql_gastos_presupuesto text;
	datos_gasto_presupuesto xml;
	presupuesto_mes_actual text;

	strValor text;
	no_partidas int;
	numero_partida int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin 	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1]; 
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	anio_en_curso := substring(fecha_operacion,1,4);
	mes_en_curso := substring(fecha_operacion,6,2);

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	

	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		clave_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_clave_gasto/text()',dataxml))[1], '');
		desc_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_desc_gasto/text()',dataxml))[1], '');
		monto_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_monto_gasto/text()',dataxml))[1], '0');
		
		datos_gasto := '<document></document>';
		select count(*) into ctd_gastos from keplersc.kdkgastos where c1=clave_gasto and c2=anio_en_curso;
		if ctd_gastos > 0 then
	
			sql_gastos := format('select %1$s as cargos_mes_actual,
				%2$s as abonos_mes_actual
		 	  from keplersc.kdkgastos where c1=%3$L and c2=%4$L ', 
			concat('c', 3 + mes_en_curso::int),concat('c', 19 + mes_en_curso::int), clave_gasto, anio_en_curso);
			
			select query_to_xml(sql_gastos, false, true, '' ) :: xml into datos_gasto;
		
		end if;
		
		cargos_mes_actual := coalesce((xpath('//row/cargos_mes_actual/text()',datos_gasto))[1], '0');
		abonos_mes_actual := coalesce((xpath('//row/abonos_mes_actual/text()',datos_gasto))[1], '0');
	
		total_gastado := cargos_mes_actual::numeric - abonos_mes_actual::numeric;
	
		cargos_total := total_gastado + monto_gasto;
	
		sql_gastos_presupuesto := format('select %1$s as presupuesto_mes_actual
		  from keplersc.kdcatgastos where c1=%2$L ', 
		concat('c', 12 + mes_en_curso::int), clave_gasto);
			
		select query_to_xml(sql_gastos_presupuesto, false, true, '' ) :: xml into datos_gasto_presupuesto;
	
		presupuesto_mes_actual := coalesce((xpath('//row/presupuesto_mes_actual/text()',datos_gasto_presupuesto))[1], '0');

		if cargos_total > presupuesto_mes_actual::numeric then
		
			--TODO, ver si se debe descomentar	
			--select c5 into privilegios_admin from keplersc.kdusrinfo where c1=usuario_movto;
			--if privilegios_admin <> 'S' then
							
				raise exception 'Error, El Gasto: % : % tiene un presupuesto de: % , y con lo acumulado quiere gastar: % ',
				clave_gasto, desc_gasto,presupuesto_mes_actual,cargos_total;
				
			--end if;
		
		end if;
	
	end loop;
		
	resultado := 1;
	mensaje := '';
	adicionales := '';
	
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := '0';
		mensaje := 'verify_ocompra() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

	
end;
$function$
