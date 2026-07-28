CREATE OR REPLACE FUNCTION keplersc.normalizar_tablas_paquetes()
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: integra las tablas de paquetes
--Autor: Luis Leal
--Fecha: 02/02/2023
--Bitacora de cambios
declare
	

	--loops
	paquete text;


	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	

	for paquete in select c4 from keplersc.kdspaq  
	loop 
		
		raise notice '%' , paquete;
		
		
	end loop;


	

exception
	when others then
		resultado := 0;
		mensaje := 'normalizar_tablas_paquetes() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
