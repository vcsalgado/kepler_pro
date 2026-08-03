CREATE OR REPLACE FUNCTION keplersc.cat_lineas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de líneas KDIVL
--Autor: Miriam Santana
--Fecha: 27/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_linea text = '';
	descripcion text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_linea := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_linea is null then 
			raise exception 'Debe seleccionar una línea de vehículo';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de la línea';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdivl  
			(c1,c2) 
		values(
			cve_linea,descripcion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdivl
			set c2=descripcion 
			where c1=cve_linea;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdivl
			where c1=cve_linea;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_linea;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_lineas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
