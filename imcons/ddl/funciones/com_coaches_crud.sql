CREATE OR REPLACE FUNCTION keplersc.com_coaches_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de coaches KDCATCOACH
--Autor: Miriam Santana
--Fecha: 17/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_coach text = '';
	nombre text = '';
	cve_usuario text = '';
	status text = '';
	cve_esquema text = '';
	sucursal_id text ='';
	crud text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_coach := (xpath('//document/k_coach/text()', dataxml))[1];
	nombre := (xpath('//document/k_nombre/text()', dataxml))[1];
	cve_usuario := coalesce((xpath('//document/k_usuario/text()', dataxml))[1],'');
	status := coalesce((xpath('//document/k_status/text()', dataxml))[1],'I');
	cve_esquema := coalesce((xpath('//document/k_esquema/text()', dataxml))[1],'');
	sucursal_id := (xpath('//document/k_sucn/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
		if clave_coach is null then 
			raise exception 'Debe seleccionar un coach';
		end if;
		if nombre is null then 
			raise exception 'Debe ingresar el nombre del coach';
		end if;
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdcatcoach 
			(c1,c2,c3,c4,c5,c6) 
		values(
			clave_coach,nombre,cve_usuario,status,sucursal_id,cve_esquema);
	end if;

	if crud = 'Modificar' then
		update keplersc.kdcatcoach 
			set c2=nombre,
				c3=cve_usuario, 
				c4=status,
				c6=cve_esquema 
			where c1=clave_coach and c5=sucursal_id;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdcatcoach 
			where c1=clave_coach and c5=sucursal_id;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_coach;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_coaches_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
