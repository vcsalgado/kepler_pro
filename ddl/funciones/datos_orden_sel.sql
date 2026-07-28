CREATE OR REPLACE FUNCTION keplersc.datos_orden_sel(dataxml xml)
 RETURNS TABLE(datos_orden xml, datos_puntos xml, datos_sintomas xml, datos_cli_vin xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Selecciona datos de la orden
--Autor: Luis Leal
--Fecha: 14/06/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	folio_orden text;
	tipo_orden text;
	vin text;
	placas text;
	clave_cliente text = '';

	sql_datos_orden text = '';
	sql_datos_puntos text = '';
	sql_datos_sintomas text = '';

	params xml;

begin
	
	
	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text; 
	folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text; 
	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text;
	clave_cliente := coalesce((xpath('//document/clave_cliente/text()', dataxml))[1]::text,'')::text; 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text; 

	sql_datos_orden := format('select ord.c2 as tipo_orden, ord.c2 as tipo_orden_bus ,
	ord.c3 as folio_orden, ord.c3 as folio_orden_bus, ord.c7 as flujo_admon, 
	ord.c22 as recepcionista, ord.c4 as fecha_captura_orden, ord.c5 as hora_captura_orden,
	ord.c6 as vin, ord.c6 as vin_bus, ord.c10 as clave_cliente, ord.c10 as clave_cliente_bus, ord.c19 as bonete,
	ord.c20 as kms,ord.c21 as placas_bus, ord.c21 as placas, ord.c55 as siniestro, 
	ord.c53 as cli_desea_ser_contactado, ord.c54 as contacto,
	ord.c24 as observaciones ,ent.c4 as fecha_entrega ,ent.c5 as hora_entrega, ent.c6 as fecha_original,
	ent.c7 as hora_original , cit.c2 as folio_cita, cit.c3 as cve_tmkt
	from keplersc.kdord as ord left outer join keplersc.kdordent as ent
	on ent.c1=ord.c1 and ent.c2=ord.c2 and ent.c3=ord.c3
	left outer join keplersc.kdctasser as cit on cit.c1=ord.c1 and cit.c21=ord.c2 and cit.c22=ord.c3
	where ord.c1=%1$L and ord.c2=%2$L', sucursal_id,tipo_orden); 
 	if folio_orden <> '' then 
 		sql_datos_orden := concat(sql_datos_orden, format(' and ord.c3=%1$L', folio_orden));
 	end if;
 	if clave_cliente <> '' then 
		sql_datos_orden := concat(sql_datos_orden, format(' and ord.c10=%1$L', clave_cliente));
	end if; 
	if vin <> '' then 
		sql_datos_orden := concat(sql_datos_orden, format(' and ord.c6=%1$L', vin));
	end if; 
	if placas <> '' then 
		sql_datos_orden := concat(sql_datos_orden, format(' and ord.c21=%1$L', placas));
	end if;
	
	sql_datos_orden := concat(sql_datos_orden, ' order by ord.c3 desc limit 1');	

	select query_to_xml(sql_datos_orden, false, true, '' ) :: xml into datos_orden;

	folio_orden := (xpath('//row/folio_orden/text()', datos_orden))[1];
	tipo_orden := (xpath('//row/tipo_orden/text()', datos_orden))[1];
	
	sql_datos_puntos := format('select pun.c6 as tipo_punto, cat.c2 desc_punto, 
	pun.c37 as tipo_operario,oper.c2 as desc_operario,  pun.c5 as clave_paquete, pun.c50 as clave_campana,
	pun.c8 as trabajo_a_realizar, pun.c40 as horas, paq.c10 as precio_punto,pun.c7 as status
	from keplersc.kdord as ord left outer join keplersc.kdpun as pun on pun.c1=ord.c1 and pun.c2=ord.c2
	and pun.c3=ord.c3 left outer join keplersc.kdserie as ser on ser.c1=ord.c6 
	left outer join keplersc.kdspaq as paq on paq.c1=ser.c2 and paq.c2=ser.c3 and paq.c4=pun.c5
	inner join keplersc.catpuntos as cat on cat.c1=pun.c6 inner join keplersc.kdtoper as oper on oper.c1=pun.c37
	where ord.c1=%1$L and ord.c2=%2$L and ord.c3=%3$L order by pun.c4 ', sucursal_id, tipo_orden, folio_orden);
	select query_to_xml(sql_datos_puntos, false, true, '' ) :: xml into datos_puntos;
	
	sql_datos_sintomas := format('select sint.c6 as tipo_sintoma, sint.c7 as clave_sintoma
	,vals.c3 as desc_sintoma, sint.c8 as cmnts_sintoma, sint.c4 as punto_sintoma
	from keplersc.kdordsint as sint inner join keplersc.kdvaltipsin as vals on vals.c1=sint.c6
	and vals.c2=sint.c7 where sint.c1=%1$L and sint.c2=%2$L and sint.c3=%3$L order by sint.c5 ', 
	sucursal_id, tipo_orden, folio_orden);
	select query_to_xml(sql_datos_sintomas, false, true, '' ) :: xml into datos_sintomas;
	

	clave_cliente := (xpath('//row/clave_cliente/text()', datos_orden))[1];
	vin := (xpath('//row/vin/text()', datos_orden))[1];
	placas := (xpath('//row/placas/text()', datos_orden))[1];
	params := format('<document>%1$s</document>',xmlforest(sucursal_id as sucursal_id,
	clave_cliente as clave_cliente, vin as vin, placas as placas));

	select datos into datos_cli_vin from keplersc.cli_vin_sel(params);

	return query
	select datos_orden, datos_puntos, datos_sintomas, datos_cli_vin;
	
exception
	when others then
		raise exception '%', 'Sin Resultados.';
end;
$function$
