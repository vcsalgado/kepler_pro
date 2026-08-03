CREATE OR REPLACE FUNCTION keplersc.gastos_alta_ocompra(dataxml xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: guarda Orden de Compra
--Autor: Luis Leal
--Fecha: 23/02/23
declare
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text; 
	tipo_clave text;
	nombre_prov text = '';
	fecha_operacion text;
	anio text;
	mes_en_curso text;

	--montos--
	iva text;
	monto text;

	--loop--
	clave_gasto text;
	desc_gasto text;
	monto_gasto text;

	sql_datos_sel text;
	datos_sel xml;
	ctd_gastos int;
	cargos_mes_actual numeric;
	sql_datos_update text;
	numero_partida int;
	strValor text;
	no_partidas int;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	nombre_prov := (xpath('//document/k_clave/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1]; 
	iva := coalesce((xpath('//document/k_iva/text()', dataxml))[1]::text,'0.00')::text;
	monto := coalesce((xpath('//document/k_monto/text()', dataxml))[1]::text,'0.00')::text; 
	anio := substring(fecha_operacion, 1,4);
	mes_en_curso := substring(fecha_operacion,6,2);

	insert into keplersc.kdgocompra (c1,c2,c3,c4,c5,c6, c7,c8,c9)
	values(sucursal_id,genero,naturaleza,grupo::int,tipo_clave::int,folio_operacion,
	 nombre_prov, iva::numeric ,monto::numeric);

	--Partidas
	strValor := (xpath('//document/k_mov/no_partidas/text()',dataxml))[1];
	no_partidas := strValor::integer;	


	numero_partida := 0;

	for cont in 0..no_partidas - 1 loop
		
		clave_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_clave_gasto/text()',dataxml))[1], '');
		desc_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_desc_gasto/text()',dataxml))[1], '');
		monto_gasto := coalesce((xpath('//document/k_mov/r' ||cont||'/k_monto_gasto/text()',dataxml))[1], '0');
					
		if clave_gasto <> '' then
		
			insert into keplersc.kdgocompradet (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12)
			values(sucursal_id,genero,naturaleza,grupo::int,tipo_clave::int,folio_operacion,cont + 1,
			clave_gasto,desc_gasto,monto_gasto::numeric, 0, nombre_prov);
		
			insert into keplersc.kdegastos (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10, c11)
			values(sucursal_id, clave_gasto, genero,naturaleza,grupo::int, tipo_clave::int,
			folio_operacion, cont + 1,fecha_operacion::date, 'C', monto_gasto::numeric);
		
		
			--RESUELVE GASTOS_ALTA_K_PRESUPUESTOS
			datos_sel := '<document></document>';
			select count(*) into ctd_gastos from keplersc.kdkgastos where c1=clave_gasto and c2=anio;
			if ctd_gastos > 0 then
			
				sql_datos_sel := format('select %1$s as cargos_mes_actual from keplersc.kdkgastos
				  where c1=%2$L and c2=%3$L', concat('c', 3 + mes_en_curso::int ), clave_gasto, anio);
				select query_to_xml(sql_datos_sel, false, true, '' ) :: xml into datos_sel;
			
			else
				insert into keplersc.kdkgastos(c1,c2) values(clave_gasto,anio);
			end if;
		
			cargos_mes_actual := coalesce((xpath('//row/cargos_mes_actual/text()',datos_sel))[1], '0');		
		
			sql_datos_update := format( 'update keplersc.kdkgastos set %1$s=%2$s where c1=%3$L and c2=%4$L',
			concat('c', 3 + mes_en_curso::int ),monto_gasto::numeric + cargos_mes_actual,clave_gasto,anio);
		
			execute sql_datos_update;
		
		end if;
		
	end loop ;	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'gastos_alta_ocompra() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
