CREATE OR REPLACE FUNCTION keplersc.carga_refacciones_sel(dataxml xml)
 RETURNS TABLE(xml_necesarias xml, xml_cargadas xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: carga_refacciones_sel
--Autor: Luis Leal
--Fecha: 25/01/2022
--Bitacora de cambios
--Autor: Luis Leal
--Fecha: 28/12/2022
--Descripcion: se agregaron refacciones necesarias y cargadas
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	tipo_orden text = '';
	orden text = '';
	serie_vehiculo text = '';	

	--variables loop
	punto numeric;
	calve_kit text = '';
	tipo_punto text = '';
	marca text = '';
	modelo text = '';
	clave_ref text = '';
	cantidad text = '';
	ref_desc text = '';
	unidad text = '';
	unitario text = '';
	importe text = '';
	folio text;

	cve_original text = '';
	cve_actual text = '';
	cadena_reemplazo text = '';
	len_cadena int = 0;
	refaccion_en_cadena text = '';
	prod_original text = '';

	expXml text = ''; 
	contador_refs_necesarias int = 0;
	contador_refs_cargadas int = 0;
	xml_refs_necesarias text = '';
	xml_refs_cargadas text = '';
	xml_necesarias text = ''; 
	xml_cargadas text = '';


begin
	--raise notice '%', dataxml;	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	tipo_orden := (xpath('//document/tipo_orden/text()', dataxml))[1];
	orden := (xpath('//document/orden/text()', dataxml))[1];
	serie_vehiculo := (xpath('//document/ident/text()', dataxml))[1];

	select c2,c3 into marca,modelo from keplersc.kdserie where c1=serie_vehiculo;
	if not found then
		raise exception 'Orden sin Número de Serie ';
	end if;

	for punto,calve_kit,tipo_punto in select c4,c5,c6 from keplersc.kdpun where c1=sucursal_id and c2=tipo_orden and c3=orden
		loop 
									
			if tipo_punto = 'S'  then 			
			-----------------NECESARIAS------------------------
				for clave_ref,cantidad in select c6,c7 from keplersc.kdspaqm where c4=calve_kit and c1=marca and c2=modelo
				loop
					
					expXml:= format('<document><clave_producto>%1$s</clave_producto><fecha>%2$s</fecha>
					<criterio_fecha>%3$s</criterio_fecha></document>',clave_ref,current_date,'N');
					select * into cve_original, cve_actual, cadena_reemplazo from keplersc.prod_cadena_reemplazo(expXml::xml);
						
					select xmlforest(clave_ref as articulo_necesario, cantidad as cantidad,  punto as punto,
					cadena_reemplazo as cadena_reemplazo) into xml_refs_necesarias::text;
						 				
					xml_necesarias := concat(xml_necesarias, format('<r%1$s>%2$s</r%1$s>' ,contador_refs_necesarias, xml_refs_necesarias ));
					
					contador_refs_necesarias := contador_refs_necesarias + 1;
					
				end loop;
		
			end if;
		
		 --------------------CARGADAS------------------
			for clave_ref,cantidad, importe, folio in select c11,c13,c16,c9 from keplersc.kdref where c1=sucursal_id
			and c2=tipo_orden and c3=orden and c4=punto
			loop 
				select * into prod_original from keplersc.prod_obtener_original(clave_ref);		
				select  xmlforest(clave_ref as articulo_cargado,cantidad as cantidad, 
				importe as monto ,punto as punto, folio as folio, prod_original as k_partesel) into xml_refs_cargadas;
							
				xml_cargadas :=  concat(xml_cargadas,format('<r%1$s>%2$s</r%1$s>' ,contador_refs_cargadas, xml_refs_cargadas ));

				contador_refs_cargadas := contador_refs_cargadas + 1;
			
			end loop;

		end loop;

	return query
	select xml_necesarias::xml, xml_cargadas::xml;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
