CREATE OR REPLACE FUNCTION keplersc.cat_precarga_serie(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza precarga de informacion de una serie en el catalogo de series (tabla KDSERIE)
--Autor: Miriam Santana
--Fecha: 19/Oct/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id  text;
	cve_inventario text = '';	
	serie text = '';
	inventario text = '';
	asterisco text = '';

	--Variables de uso general
	sqlExp text;

	--Variables de retorno
	xmlResultado xml;

begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	serie := (xpath('//document/serie/text()', dataxml))[1];
	inventario := coalesce((xpath('//document/inventario/text()', dataxml))[1]::text,'')::text;
	--sucursal_id='01';

	--obtiene ultimo no. numero inventario vendido
raise notice 'inve:% sucursal:%',inventario,sucursal_id;
	if inventario = '' or xpath_exists('//document/inventario/text()', dataxml) = false then
		if sucursal_id = '*' then
			select c1,c2 into sucursal_id,inventario from keplersc.kdinf k 	
				where c5=serie		
				order by c24 desc limit 1;
		else 	
			select c2 into inventario from keplersc.kdinf k 	
				where c5=serie		
				order by c24 desc limit 1;
		end if;
	end if;
raise notice 'inve:% suc:%',inventario,sucursal_id;
	--Inventario de auto nuevo
	if (substring(trim(inventario),8,1)='N') then
		sqlExp = format('select mar.c1 as input_marca, mar.c2 as k_desc_marca,inf.c4 as desc_modelo,inf.c15 as input_anio,right(inf.c34,20) as input_color,
				inf.c6 as input_motor,inf.c8 as input_transmision,ctEB.c16 as input_fecha_venta,ctEB.c29 as input_concesionario,
				con.c2 as k_desc_concesionario,ctEB.c33 as input_contacto, ud.c3 as k_nombre_contacto, ctEb.c11 as input_kilometraje,
				ctEb.c5 as input_placas,ctEB.c40 as input_codigo_planta,case when vtas.c34>0 then ''S'' else ''N'' end as garantia_ext,
				case when vtas.c35>0 then ''S'' else ''N'' end as segvehicular
				from keplersc.kdinf inf
				left join keplersc.kdctasbienvser ctEB on ctEB.c1=inf.c1 and ctEB.c15=inf.c2
				left join keplersc.kdud ud on ud.c2=ctEB.c33
				left join (select * from keplersc.kdventas		
				where c1=%1$L and c2=%2$L and c10=0   
				order by c3 desc limit 1) vtas on vtas.c1=inf.c1 and vtas.c2=inf.c2
				left join keplersc.kdmarca mar on mar.c1=inf.c17
				left join keplersc.kdconc con on con.c1=ctEB.c29
				where inf.c1=%1$L and inf.c5=%3$L
				order by inf.c24 desc limit 1',sucursal_id,inventario,serie);
	else 
		sqlExp = format('select inf.c85||'' ''||inf.c4 as desc_modelo,inf.c87 as input_anio,right(inf.c34,20) as input_color,
				inf.c88 as input_version,
				inf.c6 as input_motor,inf.c8 as input_transmision,ctEB.c16 as input_fecha_venta,ctEB.c29 as input_concesionario,
				con.c2 as k_desc_concesionario,ctEB.c33 as input_contacto, ud.c3 as k_nombre_contacto, ctEb.c11 as input_kilometraje,
				ctEb.c5 as input_placas,ctEB.c40 as input_codigo_planta,case when vtas.c34>0 then ''S'' else ''N'' end as garantia_ext,
				case when vtas.c35>0 then ''S'' else ''N'' end as segvehicular
				from keplersc.kdinf inf
				left join keplersc.kdctasbienvser ctEB on ctEB.c1=inf.c1 and ctEB.c15=inf.c2
				left join keplersc.kdud ud on ud.c2=ctEB.c33
				left join (select * from keplersc.kdventas		
				where c1=%1$L and c2=%2$L and c10=0   
				order by c3 desc limit 1) vtas on vtas.c1=inf.c1 and vtas.c2=inf.c2
				left join keplersc.kdconc con on con.c1=ctEB.c29
				where inf.c1=%1$L and inf.c5=%3$L
				order by inf.c24 desc limit 1',sucursal_id,inventario,serie);
	
	end if;
raise notice '%',sqlExp;
	select query_to_xml(sqlExp,false,true,'') into xmlResultado;
	return xmlResultado;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
