CREATE OR REPLACE FUNCTION keplersc.cat_reemplazos_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de Reemplazos KDINR
--Autor: Victor Salgado
--Fecha: 25/01/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_original text = '';
	clave_reemplazo text = '';
	crud text = '';

	--variables de proceso
	strReemplazo text= '';
	totElements int = 0;
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_original := (xpath('//document/k_clave_original/text()', dataxml))[1];
	clave_reemplazo := coalesce((xpath('//document/k_clave_reemplazo/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if clave_original is null then 
		raise exception 'Debe proporcionar un producto original';
	end if;
	if clave_reemplazo is null then 
		raise exception 'Debe proporcionar un producto reemplazo';
	end if;

	if crud = 'NUEVO' then
		--Obtener cadena de reemplazos de original
		select cadena_reemplazo into strReemplazo from keplersc.prod_cadena_reemplazo(clave_original);
		totElements := (select array_upper(string_to_array(strReemplazo, '|'),1));
		clave_original:=(select (string_to_array(strReemplazo, '|'))[totElements]);
--raise exception 'original %; reemplazo %',clave_original,clave_reemplazo;	
		insert into keplersc.kdinr (c1,c2) values(clave_reemplazo,clave_original);
	end if;

	if crud = 'MODIFICAR' then
		raise exception 'Acción no implementada, solicite soporte a mesa de ayuda';
	end if;

	if crud = 'ELIMINAR' then
		raise exception 'Acción no implementada, solicite soporte a mesa de ayuda';
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_reemplazo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_reemplazos_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
