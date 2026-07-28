CREATE OR REPLACE FUNCTION keplersc.datos_bienvenida_sel(dataxml xml)
 RETURNS TABLE(datos_bienv xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Selecciona datos del evento de bienvenida
--Autor: Miriam Santana
--Fecha: 17/10/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	clave_cliente text;
	vin text;
	inventario  text;

	sql_datos text = '';

begin
	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := coalesce((xpath('//document/clave_cliente/text()', dataxml))[1]::text,'')::text; 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	inventario := coalesce((xpath('//document/inventario/text()', dataxml))[1]::text,'')::text;

	if inventario = '' then
		raise exception 'Es necesario especificar un No. de inventario para el evento de bienvenida';
	end if;

	sql_datos :=format('select ctEB.c15 as inventario,''[''||uv.c2||''] ''||uv.c3 as desc_vendedor,
			ctEB.c15 as cve_inv, ctEB.c4 as clave_cliente,ctEB.c6 as vin,ctEB.c17 as vendedor,ctEB.c12 as fecha_cita,
			ctEB.c13 as hora_cita,case when ctEB.c25=''0'' then ''Cliente'' else ''Otro'' end as cmb_asistira,
			ctEB.c18 as persona_evento, ctEB.c19 as asistio_evento, 
			ud.c2 as cliente_id, ud.c3 as cliente_nombre,ud.c4 as cliente_calle, ud.c45 as cliente_ext, ud.c46 as cliente_int, ud.c5 as cliente_colonia, 
			ud.c6 as cliente_poblacion, ud.c47 as cliente_municipio, ud.c48 as cliente_estado, ud.c49 as cliente_pais, 
		    ud.c27 as cliente_cp, ud.c11 as cliente_correo, ud.c10 as cliente_rfc,ud.c7 as cliente_tcasa, ud.c8 as cliente_toficina, 
			ud.c9 as cliente_tmovil,  ud.c37 as cliente_extension, cpref.c1 as medio_preferido,cpref.c2 as desc_medio_preferido, ctEB.c32 as num_preferido,
			tsn.c2 as tipo_snack, ctEB.c22 as desc_snack, tbeb.c2 as tipo_bebida, ctEB.c24 as desc_bebida, 

			udp.c2 as propietario_id, udp.c3 as propietario_nombre,udp.c4 as propietario_calle, udp.c45 as propietario_ext, udp.c46 as propietario_int, udp.c5 as propietario_colonia, 
			udp.c6 as propietario_poblacion, udp.c47 as propietario_municipio, udp.c48 as propietario_estado, udp.c49 as propietario_pais, 
		    udp.c27 as propietario_cp, udp.c11 as propietario_correo, udp.c10 as propietario_rfc,udp.c7 as propietario_tcasa, udp.c8 as propietario_toficina, 
			udp.c9 as propietario_tmovil,  udp.c37 as propietario_extension, cprefp.c1 as medio_preferido_prop,cprefp.c2 as desc_medio_preferido_prop, ctEB.c39 as num_preferido_prop,
			tsnp.c2 as tipo_snack_prop, ctEB.c35 as desc_snack_prop, tbebp.c2 as tipo_bebida_prop, ctEB.c37 as desc_bebida_prop,  
 
			ctEB.c9 as serie,ctEB.c7 as marca, ctEB.c8 as modelo, ctEB.c10 as anio,ctEB.c14 as color,ctEB.c11 as kms,ctEB.c5 as placas, 
			ctEB.c29 as concesionario,ctEB.c40 as codigo
			from keplersc.kdctasbienvser ctEB 
			inner join keplersc.kdud ud on ud.c2=ctEB.c4
			left join keplersc.kdud udp on udp.c2=ctEB.c33
			left join keplersc.kdsertiposnack tsn on tsn.c1=ctEB.c21
			left join keplersc.kdsertipobebida tbeb on tbeb.c1=ctEB.c23
			left join keplersc.kdsercontpref cpref on cpref.c1=ctEB.c31

			left join keplersc.kdsertiposnack tsnp on tsnp.c1=ctEB.c34
			left join keplersc.kdsertipobebida tbebp on tbebp.c1=ctEB.c36
			left join keplersc.kdsercontpref cprefp on cprefp.c1=ctEB.c38

			left join keplersc.kduv uv on uv.c1=ctEB.c1 and uv.c2=ctEB.c17
			where ctEB.c1=%1$L', sucursal_id); 
	
	if inventario <> '' then 
 		sql_datos := concat(sql_datos, format(' and ctEB.c15=%1$L', inventario));
 	end if;
	sql_datos := concat(sql_datos, ' order by ctEB.c2 desc limit 1');	
	--raise notice '%',sql_datos_cita;
	select query_to_xml(sql_datos, false, true, '' ) :: xml into datos_bienv;	

	return query select datos_bienv;
	
exception
	when others then
		raise exception '%', 'Sin Resultados.'|| sqlerrm;
end;
$function$
