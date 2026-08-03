CREATE OR REPLACE FUNCTION keplersc.datos_citabienv_sel(dataxml xml)
 RETURNS TABLE(datos_cita xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Selecciona datos de la cita de evento de bienvenida
--Autor: Miriam Santana
--Fecha: 06/10/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	folio_cita text;
	tipo_cita text;
	clave_cliente text;
	vin text;
	placas text;
	inventario  text;

	sql_datos_cita text = '';
	sql_datos_puntos text = '';
	sql_datos_sintomas text = '';

	params xml;

begin
	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text; 
	folio_cita := coalesce((xpath('//document/folio_cita/text()', dataxml))[1]::text,'')::text; 
	tipo_cita := coalesce((xpath('//document/tipo_cita/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := coalesce((xpath('//document/clave_cliente/text()', dataxml))[1]::text,'')::text; 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text;
	inventario := coalesce((xpath('//document/inventario/text()', dataxml))[1]::text,'')::text;

	if inventario = '' then
		raise exception 'Es necesario especificar un No. de inventario para el evento de bienvenida';
	end if;

sql_datos_cita :=format('select ctEB.c15 as inventario,''[''||uv.c2||''] ''||uv.c3 as desc_vendedor,ctEB.c3 as cve_tmkt,
			ctEB.c16 as fecha_captura,''Evento Bienvenida'' as tipo_cita,ctEB.c2 as folio_cita, ctEB.c2 as fol_cita,  ctEB.c4 as clave_cliente,
			ctEB.c11 as kms, ctEB.c6 as vin,ctEB.c17 as vendedor,ctEB.c12 as fecha_cita, ctEB.c13 as hora_cita, 
			ctEB.c26 as fecha_confirmacion,ctEB.c27 as hora_confirmacion, ctEB.c28 as persona_confirmo,
			case when ctEB.c25=''0'' then ''Cliente'' else ''Otro'' end as cmb_asistira,
			ctEB.c18 as persona_evento, ctEB.c19 as asistio_evento, ctEB.c20 as estatus_cita,
			ud.c2 as cliente_id, ud.c3 as cliente_nombre,ud.c4 as cliente_calle, ud.c45 as cliente_ext, ud.c46 as cliente_int, ud.c5 as cliente_colonia, 
			ud.c6 as cliente_poblacion, ud.c47 as cliente_municipio, ud.c48 as cliente_estado, ud.c49 as cliente_pais, 
		    ud.c27 as cliente_cp, ud.c11 as cliente_correo, ud.c10 as cliente_rfc,ud.c7 as cliente_tcasa, ud.c8 as cliente_toficina, 
			ud.c9 as cliente_tmovil,  ud.c37 as cliente_extension, cpref.c1 as medio_preferido,cpref.c2 as desc_medio_preferido, ctEB.c32 as num_preferido,
			tsn.c2 as tipo_snack, ctEB.c22 as desc_snack, tbeb.c2 as tipo_bebida, ctEB.c24 as desc_bebida,  
			ctEB.c9 as serie,ctEB.c7 as marca, ctEB.c8 as modelo, ctEB.c10 as anio,ctEB.c14 as color,ctEB.c11 as kms,ctEB.c5 as placas, 
			ctEB.c29 as concesionario, ctEB.c30 as observaciones
			from keplersc.kdctasbienvser ctEB 
			inner join keplersc.kdud ud on ud.c2=ctEB.c4
			left join keplersc.kdsertiposnack tsn on tsn.c1=ctEB.c21
			left join keplersc.kdsertipobebida tbeb on tbeb.c1=ctEB.c23
			left join keplersc.kdsercontpref cpref on cpref.c1=ctEB.c31
			left join keplersc.kduv uv on uv.c1=ctEB.c1 and uv.c2=ctEB.c17
			where ctEB.c1=%1$L', sucursal_id); 
	
	if inventario <> '' then 
 		sql_datos_cita := concat(sql_datos_cita, format(' and ctEB.c15=%1$L', inventario));
 	end if;
	if folio_cita <> '' then 
 		sql_datos_cita := concat(sql_datos_cita, format(' and ctEB.c2=%1$L', folio_cita));
 	end if;
	if clave_cliente <> '' then 
		sql_datos_cita := concat(sql_datos_cita, format(' and ctEB.c4=%1$L', clave_cliente));
	end if; 
	if vin <> '' then 
		sql_datos_cita := concat(sql_datos_cita, format(' and ctEB.c9 =%1$L', vin));
	end if; 

	sql_datos_cita := concat(sql_datos_cita, ' order by ctEB.c2 desc limit 1');	
	--raise notice '%',sql_datos_cita;
	select query_to_xml(sql_datos_cita, false, true, '' ) :: xml into datos_cita;	

	return query select datos_cita;
	
exception
	when others then
		raise exception '%', 'Sin Resultados.'|| sqlerrm;
end;
$function$
