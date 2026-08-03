CREATE OR REPLACE FUNCTION keplersc.cat_claspaq_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de clasificacion de paquetes kdclaspaq
--Autor: Gad Miranda
--Fecha: 12/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_claspaq text = '';
	descripcion text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_claspaq := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_claspaq is null then 
			raise exception 'Debe seleccionar una clasificacion de paquete';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la clasificacion de paquete';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdclaspaq  
			(c1,c2) 
		values(
			cve_claspaq,descripcion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdclaspaq
			set c2=descripcion 
			where c1=cve_claspaq;
	end if;

	if crud = 'ELIMINAR' then
		raise exception 'Funcion no implementada';
		--delete from keplersc.kdclaspaq
		--	where c1=cve_claspaq;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_claspaq;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_claspaq_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
