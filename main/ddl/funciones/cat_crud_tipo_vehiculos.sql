CREATE OR REPLACE FUNCTION keplersc.cat_crud_tipo_vehiculos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de vehiculos 	
--Autor: Gad Miranda
--Fecha: 31/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_tipo_vehiculo text = '';
	descripcion text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_tipo_vehiculo := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_tipo_vehiculo is null then 
			raise exception 'Debe seleccionar un Tipo vehiculo';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de Tipo vehiculo';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdtipoveh
			(c1,c2) 
		values(
			cve_tipo_vehiculo,descripcion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdtipoveh
			set c2=descripcion 
			where c1=cve_tipo_vehiculo;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdtipoveh
			where c1=cve_tipo_vehiculo;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_tipo_vehiculo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_tipo_vehiculo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
