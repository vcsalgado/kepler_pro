CREATE OR REPLACE FUNCTION keplersc.base_function_transac(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	variable_id text = '';	

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	variable_id := (xpath('//document/valor/text()', dataxml))[1];



	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
