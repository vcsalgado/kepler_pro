CREATE OR REPLACE FUNCTION keplersc.vendedores_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: crud del catalogo de vendedores
--Autor: Luis Leal
--Fecha: 18/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text;
	clave_ven text ;
	nombre text;
	empresa text;
	usuario text;
	activo text;
	grupo text;
	esquema text;
	fecha_ingreso date;
	crud text = '';

	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	sucursal_id := upper((xpath('//document/sucursal_id/text()', dataxml))[1]::text);
	clave_ven := upper((xpath('//document/clave_ven/text()', dataxml))[1]::text);
	nombre := coalesce((xpath('//document/nombre/text()', dataxml))[1]::text,'')::text;
	empresa := coalesce((xpath('//document/empresa/text()', dataxml))[1]::text,'')::text;
	usuario := coalesce((xpath('//document/usuario/text()', dataxml))[1]::text,'')::text;
	activo := coalesce((xpath('//document/activo/text()', dataxml))[1]::text,'')::text;
	grupo := coalesce((xpath('//document/grupo/text()', dataxml))[1]::text,'')::text;
	esquema := coalesce((xpath('//document/esquema/text()', dataxml))[1]::text,'')::text;
	fecha_ingreso := coalesce((xpath('//document/fecha_ingreso/text()', dataxml))[1]::text,'')::text;
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'Eliminar' then
	
		if sucursal_id is null then 
			raise exception 'Error no se encuentra sucursal del usuario.';
		end if;
	
		if clave_ven is null then 
			raise exception 'Debe ingresar una clave.';
		end if;
	
		if nombre = '' then 
			raise exception 'Tiene que ingresar un nombre.';
		end if;

/* Se debe permitir registrar sin usuario de sistema	
		if usuario = '' then 
			raise exception 'Tiene que ingresar un usuario.';
		end if;
*/	
		if activo = '' then 
			raise exception 'Tiene que ingresar si esta activo o no el vendedor.';
		end if;
	
	end if; 

	if crud = 'Nuevo' then		
		insert into keplersc.kduv(c1,c2,c3,c4,c5,c6,c7,c8,c9) values(sucursal_id, clave_ven, nombre, empresa, usuario, activo, grupo, esquema, fecha_ingreso);
	end if;

	if crud = 'Modificar' then
		update keplersc.kduv set c3=nombre,c4=empresa, c5=usuario, c6=activo, c7=grupo, c8=esquema, c9=fecha_ingreso where c1=sucursal_id and c2=clave_ven ;
	end if;

	if crud = 'Eliminar' then
		delete from keplersc.kduv where c1=sucursal_id and c2=clave_ven ;	
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave_ven;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
	
		mensaje := 'vendedores_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		

		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
