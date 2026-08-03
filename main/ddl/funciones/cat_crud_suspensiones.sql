CREATE OR REPLACE FUNCTION keplersc.cat_crud_suspensiones(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de suspensiones
--Autor: Gad Miranda
--Fecha: 31/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_suspension text = '';
	descripcion text = '';
	refaccion text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_suspension := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	refaccion := (xpath('//document/k_refaccion/r0/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_suspension is null then 
			raise exception 'Debe seleccionar una línea de vehículo';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de la línea';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdsusp
			(c1,c2,c3) 
		values(
			cve_suspension,descripcion,refaccion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdsusp
			set c2=descripcion, c3 = refaccion
			where c1=cve_suspension;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdsusp
			where c1=cve_suspension;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_suspension;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_consecionarios() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
