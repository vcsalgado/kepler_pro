CREATE OR REPLACE FUNCTION keplersc.com_asesorcontcent_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de asesore contact center KDASESORCC 
--Autor: Miriam Santana
--Fecha: 19/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_asesor text = '';
	nombre text = '';
	sucursal_id text ='';
	esquema text = '';
	crud text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_asesor := (xpath('//document/k_asesor/text()', dataxml))[1];
	nombre := (xpath('//document/k_nombre/text()', dataxml))[1];
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if clave_asesor is null then 
			raise exception 'Debe seleccionar un asesor';
		end if;
		if nombre is null then 
			raise exception 'Debe ingresar el nombre del asesor';
		end if;
		if esquema is null then 
				raise exception 'Debe especificar un esquema';
			end if;
		end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdasesorcc 
			(c1,c2,c8,c9) 
		values(
			clave_asesor,nombre,esquema,sucursal_id);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdasesorcc
			set c2=nombre,
				c8=esquema
			where c1=clave_asesor and c9=sucursal_id;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdasesorcc
			where c1=clave_asesor and c9=sucursal_id;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_asesor;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_asesorcontcent_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
