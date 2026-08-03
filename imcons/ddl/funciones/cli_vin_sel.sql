CREATE OR REPLACE FUNCTION keplersc.cli_vin_sel(dataxml xml)
 RETURNS TABLE(datos xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: selecciona datos cliente y su vehiculo
--Autor: Luis Leal
--Fecha: 16/06/2022
--Bitacora de cambios
declare

	sucursal_id text = '';
	vin text;
	placas text;
	clave_cliente text;
	sql_datos text = '';

begin

	sucursal_id := coalesce((xpath('//document/sucursal_id/text()', dataxml))[1]::text,'')::text; 
	clave_cliente := coalesce((xpath('//document/clave_cliente/text()', dataxml))[1]::text,'')::text; 
	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	placas := coalesce((xpath('//document/placas/text()', dataxml))[1]::text,'')::text; 

	sql_datos := 'select ud.c2 as cliente_id, ud.c3 as cliente_nombre, 
	ud.c4 as cliente_calle, ud.c45 as cliente_ext, ud.c46 as cliente_int, ud.c5 as cliente_colonia, 
	ud.c6 as cliente_poblacion, ud.c47 as cliente_municipio, ud.c48 as cliente_estado, ud.c49 as cliente_pais, 
    ud.c27 as cliente_cp, ud.c11 as cliente_correo, ud.c7 as cliente_tcasa, ud.c8 as cliente_toficina, 
	ud.c9 as cliente_tmovil, ud.c10 as cliente_rfc, ud.c37 as cliente_extension,ser.c1 as vin, ser.c2 as marca, 
	ser.c3 as modelo, ser.c8 as placas , ser.c10 as color ,ser.c11 as anio,
	ser.c12 as kms, ser.c4 as serie, ser.c17 as codigo from keplersc.kdud as ud 
	left outer join keplersc.kdserie as ser on ser.c9=ud.c2'; 
	if clave_cliente <> '' then 
		sql_datos := concat(sql_datos, format(' where ud.c2=%1$L', clave_cliente));
	end if;
	if vin <> '' then 
		if clave_cliente = '' then
			sql_datos := concat(sql_datos, format(' where ser.c1=%1$L', right(vin,8)));
		else
			sql_datos := concat(sql_datos, format(' and ser.c1=%1$L', right(vin,8)));
		end if;
	end if;
	if placas <> '' then 
		if clave_cliente = '' and vin = '' then
			sql_datos := concat(sql_datos, format(' where ser.c8=%1$L', placas));
		else 
			sql_datos := concat(sql_datos, format(' and ser.c8=%1$L', placas));
		end if;
	end if;
	sql_datos := concat(sql_datos, ' order by ser.c13 desc limit 1');
raise notice '%',sql_datos;
	select query_to_xml(sql_datos, false, true, '' ) :: xml into datos;
	
	return query
	select datos;
	
exception
	when others then
		raise exception '%', 'Sin Resultados';
end;
$function$
