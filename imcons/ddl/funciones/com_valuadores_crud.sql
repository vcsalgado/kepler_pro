CREATE OR REPLACE FUNCTION keplersc.com_valuadores_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de valuadores KDCATVAL
--Autor: Miriam Santana
--Fecha: 18/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_valuador text = '';
	nombre text = '';
	sucursal_id text ='';
	crud text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_valuador := (xpath('//document/k_valuador/text()', dataxml))[1];
	nombre := (xpath('//document/k_nombre/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if clave_valuador is null then 
			raise exception 'Debe seleccionar un valuador';
		end if;
		if nombre is null then 
			raise exception 'Debe ingresar el nombre del valuador';
		end if;
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdcatval 
			(c1,c2,c3) 
		values(
			clave_valuador,nombre,sucursal_id);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdcatval
			set c2=nombre 
			where c1=clave_valuador and c3=sucursal_id;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdcatval 
			where c1=clave_valuador and c3=sucursal_id;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_valuador;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_valuadores_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
