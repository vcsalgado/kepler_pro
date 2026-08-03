CREATE OR REPLACE FUNCTION keplersc.tipos_operacion_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud del catalogo de tipos de operaciones
--Autor: Luis Leal
--Fecha: 18/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave_operacion text;
	desc_operacion text ;
	operacion_gmac text;
	crud text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave_operacion := upper((xpath('//document/clave_operacion/text()', dataxml))[1]::text);
	desc_operacion := coalesce((xpath('//document/desc_operacion/text()', dataxml))[1]::text,'')::text;
	operacion_gmac := coalesce((xpath('//document/operacion_gmac/text()', dataxml))[1]::text,'')::text;
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then

		if clave_operacion is null then 
			raise exception 'Debe ingresar una clave.';
		end if;
	
		if desc_operacion = '' then 
			raise exception 'Tiene que ingresar una descripcion.';
		end if;
	
		if operacion_gmac = '' then 
			raise exception 'Tiene que ingresar una operacion GMAC.';
		end if;
	
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kdtop(c1,c2,c3) values(clave_operacion, desc_operacion, operacion_gmac );
	end if;

	if crud = 'Modificar' then
		update keplersc.kdtop set c2=desc_operacion, c3=operacion_gmac where c1=clave_operacion  ;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kdtop where c1=clave_operacion ;	
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_operacion;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'tipos_operacion_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
