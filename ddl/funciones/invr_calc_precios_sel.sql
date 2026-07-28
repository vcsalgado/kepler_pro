CREATE OR REPLACE FUNCTION keplersc.invr_calc_precios_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Esta funcion resuelve CALCULA_PRECIO_INVR
--Parametros de entrada en xml: sucursal_id, producto, precios_request
--   precios_request contiene la cadena de precios a obtener 
--Parametros de salida xml: precios solicitados en un atributo cada uno
--Author: Victor salgado
--Fecha: 07/10/2021
--Bitacora de cambios:
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	producto text = '';
	precios_request text = '';
	usuario_movto text = '';

	--Variables de proceso
	transaccion_id text='';
	error text = '';
	lista_precios text[];
	regla_precio text='';
	strXml text = '';
	expSql text = '';
	nombre_precio text = '';
	nombre_funcion text = '';
	precio decimal = 0.00;
	strErrores text = '';
	boolErrores text = 'N';
	totalReg int = 0;

	--Variables de retorno
	xmlResultados xml;


begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto := (xpath('//document/producto/text()', dataxml))[1];
	precios_request := (xpath('//document/precios_request/text()', dataxml))[1];

	lista_precios := string_to_array(precios_request, ',');

	for i in array_lower(lista_precios,1) .. array_upper(lista_precios,1) loop
		nombre_precio := lista_precios[i];
		nombre_precio := lower(nombre_precio);
		nombre_funcion := 'keplersc.invr_calc_precio_metodo_sel';

		precio := 0.00;
		strXml := strXml || '<k_' || nombre_precio || '>';	

		expSql := format('select precio from %1$s(''<document><sucursal_id>%2$s</sucursal_id><producto>%3$s</producto>
			<nombre_precio>%4$s</nombre_precio></document>'')',nombre_funcion,sucursal_id,producto,nombre_precio);
--raise notice '%', expSql;
		select query_to_xml(expSql, false, false, '') into xmlResultados;		
		precio:= (xpath('//row/precio/text()', xmlResultados))[1];		

		strXml := strXml || precio::text;
		strXml := strXml || '</k_' || nombre_precio || '>';	
	end loop;
	--Agregar resumen de errores controlables
	if boolErrores = 'N' then
		strErrores = 'N';
	end if;
	strXml := strXml || '<errores>' || strErrores || '</errores>';

	xmlResultados := strXml::xml;

--	raise notice '%',xmlResultados;

	return xmlResultados;
exception
	when sqlstate 'P0001' then
		raise exception '%', sqlerrm;
	when others then
		error := 'keplersc.invr_calc_precios() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_calc_precios', false, SQLERRM, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
