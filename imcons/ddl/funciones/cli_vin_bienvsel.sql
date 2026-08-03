CREATE OR REPLACE FUNCTION keplersc.cli_vin_bienvsel(dataxml xml)
 RETURNS TABLE(datos xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona datos cliente y su vehiculo para el evento de bienvenida
--Autor: Miriam Santana
--Fecha: 09/10/2022
--Bitacora de cambios
declare

	sucursal_id text = '';
	vin text;
	placas text;
	clave_cliente text;
	inventario text;
	sql_datos text = '';

	totReg integer;

begin

	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := coalesce((xpath('//document/clave_cliente/text()', dataxml))[1]::text,'')::text; 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	inventario := coalesce((xpath('//document/inventario/text()', dataxml))[1]::text,'')::text;
	select count(*) into totReg 
		from keplersc.kdctasbienvser
		where c15=inventario;
	if totReg > 0 then
		sql_datos :=  format('select ud.c2 as cliente_id, ud.c3 as cliente_nombre, 
			ud.c4 as cliente_calle, ud.c45 as cliente_ext, ud.c46 as cliente_int, ud.c5 as cliente_colonia, 
			ud.c6 as cliente_poblacion, ud.c47 as cliente_municipio, ud.c48 as cliente_estado, ud.c49 as cliente_pais, 
		    ud.c27 as cliente_cp, ud.c11 as cliente_correo, ud.c7 as cliente_tcasa, ud.c8 as cliente_toficina, 
			ud.c9 as cliente_tmovil, ud.c10 as cliente_rfc, ud.c37 as cliente_extension,''Cliente'' as cmb_asistir,ud.c3 as persona_evento,''N'' as asistio_evento,	
			ctEB.c7 as marca, ctEB.c8 as modelo, ''SP'' as placas, ctEB.c14 as color ,ctEB.c10 as anio,
			0 as kms, ctEB.c9 as serie, ctEB.c29 as concesionario, ''[''||uv.c2||''] ''||uv.c3 as desc_vendedor, ctEB.c17 as vendedor
			from keplersc.kdctasbienvser ctEB
			inner join keplersc.kdud ud on ud.c2=ctEB.c4
			left join keplersc.kduv uv on uv.c1=ctEB.c1 and uv.c2=ctEB.c17
			where ctEB.c1=%1$L and ctEB.c15=%2$L',sucursal_id,inventario);
	else
		sql_datos :=  format('select ud.c2 as cliente_id, ud.c3 as cliente_nombre, 
			ud.c4 as cliente_calle, ud.c45 as cliente_ext, ud.c46 as cliente_int, ud.c5 as cliente_colonia, 
			ud.c6 as cliente_poblacion, ud.c47 as cliente_municipio, ud.c48 as cliente_estado, ud.c49 as cliente_pais, 
		    ud.c27 as cliente_cp, ud.c11 as cliente_correo, ud.c7 as cliente_tcasa, ud.c8 as cliente_toficina, 
			ud.c9 as cliente_tmovil, ud.c10 as cliente_rfc, ud.c37 as cliente_extension,''Cliente'' as cmb_asistir,ud.c3 as persona_evento,''N'' as asistio_evento,	
			inf.c17 as marca, inf.c4 as modelo, ''SP'' as placas, inf.c34 as color ,inf.c15 as anio,
			0 as kms, inf.c5 as serie
			from keplersc.kdud ud
			inner join keplersc.kdinf inf on inf.c1=%1$L and inf.c2=%2$L
			where ud.c2=(select c11 from keplersc.kdventas k 
			where c1=%1$L and c2=inf.c2 and c10=0 order by c3 desc limit 1)',sucursal_id,inventario);
	end if;
	--raise notice '%',sql_datos;
	select query_to_xml(sql_datos, false, true, '' ) :: xml into datos;
	
	return query select datos;
	
exception
	when others then
		raise exception '%', 'Sin Resultados'|| sqlerrm;
end;
$function$
