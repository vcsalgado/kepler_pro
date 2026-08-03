CREATE OR REPLACE FUNCTION keplersc.datos_cita_sel(dataxml xml)
 RETURNS TABLE(datos_cita xml, datos_puntos xml, datos_sintomas xml, datos_cli_vin xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Selecciona datos de la cita
--Autor: Luis Leal
--Fecha: 28/04/2022
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	folio_cita text;
	tipo_cita text;
	clave_cliente text;
	vin text;
	placas text;

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

	sql_datos_cita := format('select c2 as folio_cita, c2 as fol_cita, c3 as cve_tmkt, c4 as clave_cliente,
	c5 as placas_bus,c5 as placas, c11 as kms, right(c9,8) as vin , c37 as tipo_cita, c37 as tipo_cita_bus,
	c12 as fecha_cita, c13 as hora_cita , c14 as fecha_entrega, c15 as hora_entrega, c16 as fecha_captura,
	c17 as recepcionista, c20 as estatus_cita, c26 as fecha_confirmacion, 
	c27 as hora_confirmacion, c28 as persona_confirmo, c30 as observaciones,
	tipo_servicio as cmb_tipo_servicio,ubicacion_servicio as cmb_ubica_servicio,calle_rec as calle_recoleccion,
	num_ext_rec as num_ext_recoleccion,num_int_rec as num_int_recoleccion,colonia_rec as colonia_recoleccion,
	poblacion_rec as poblacion_recoleccion,municipio_rec as municipio_recoleccion,estado_rec as estado_recoleccion,
	cp_rec as cp_recoleccion,contacto_rec as contacto_recoleccion,fecha_rec as fecha_recoleccion,hora_rec as horario_recoleccion,
	regresa_domicilio,observaciones_rec as observaciones_recoleccion,promocion as cmb_promocion
	from keplersc.kdctasser where c1=%1$L ', sucursal_id ); 

	if tipo_cita <> '' then 
 		sql_datos_cita := concat(sql_datos_cita, format(' and c37=%1$L', tipo_cita));
 	end if;
 	if folio_cita <> '' then 
 		sql_datos_cita := concat(sql_datos_cita, format(' and c2=%1$L', folio_cita));
 	end if;
	if clave_cliente <> '' then 
		sql_datos_cita := concat(sql_datos_cita, format(' and c4=%1$L', clave_cliente));
	end if; 
	if vin <> '' then 
		sql_datos_cita := concat(sql_datos_cita, format(' and ( c9=%1$L or c6=%1$L ) ', vin));
	end if; 
	if placas <> '' then
		sql_datos_cita := concat(sql_datos_cita, format(' and c5=%1$L', placas));
	end if;
	sql_datos_cita := concat(sql_datos_cita, ' order by c2 desc limit 1');	
	select query_to_xml(sql_datos_cita, false, true, '' ) :: xml into datos_cita;

	raise notice 'sql_datos_cita:%',sql_datos_cita;

	folio_cita := (xpath('//row/folio_cita/text()', datos_cita))[1];

	sql_datos_puntos := format('select mov.c4 as tipo_punto, pun.c2 as desc_punto, 
	mov.c5 as tipo_operario, oper.c2 as desc_operario, mov.c6 as clave_paquete, 
	mov.c7 as trabajo_a_realizar,mov.c11 as clave_campana, mov.c9 as horas, mov.c8 as precio_punto,
	coalesce(ope.c1,'''') as clave_operario , coalesce(ope.c3, '''') as clave_operario_desc,
	mov.c12 as horario_inicio, mov.c13 as horario_fin
	from keplersc.kdctassermov as mov inner join keplersc.catpuntos as pun on pun.c1=mov.c4
	left outer join keplersc.kdtoper as oper on oper.c1=mov.c5
	left outer join keplersc.kdoper as ope on ope.c1=mov.c10
	where mov.c1=%1$L and mov.c2=%2$L order by mov.c3 ', sucursal_id, folio_cita);

	raise notice 'sql_datos_puntos:%',sql_datos_puntos;

	select query_to_xml(sql_datos_puntos, false, true, '' ) :: xml into datos_puntos;
	
	sql_datos_sintomas := format('select sint.c5 as tipo_sintoma, sint.c6 as clave_sintoma
	,vals.c3 as desc_sintoma, sint.c3 as punto_sintoma, sint.c7 as cmnts_sintoma, sint.c4 as partida_sintoma
	from keplersc.kdctassint as sint inner join keplersc.kdvaltipsin as vals on vals.c1=sint.c5
	and vals.c2=sint.c6 where sint.c1=%1$L and sint.c2=%2$L order by sint.c4 ', sucursal_id, folio_cita);
	select query_to_xml(sql_datos_sintomas, false, true, '' ) :: xml into datos_sintomas;
	
	clave_cliente := (xpath('//row/clave_cliente/text()', datos_cita))[1];
	vin := (xpath('//row/vin/text()', datos_cita))[1];
	--TODO, checar intgeracion de datos 
	--placas := (xpath('//row/placas/text()', datos_cita))[1];
	params := format('<document>%1$s</document>',xmlforest(sucursal_id as sucursal_id,
	clave_cliente as clave_cliente, vin as vin, placas as placas));
raise notice 'Params:%',params;
	select datos into datos_cli_vin from keplersc.cli_vin_sel(params);
	
	return query
	select datos_cita, datos_puntos, datos_sintomas, datos_cli_vin;
	
exception
	when others then
		raise exception '%', 'Sin Resultados.';
end;
$function$
