CREATE OR REPLACE FUNCTION keplersc.cat_crud_consecionarios(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de kdconc
--Autor: Gad Miranda
--Fecha: 01/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_consecionario text = '';
	descripcion text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_consecionario := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_consecionario is null then 
			raise exception 'Debe seleccionar una línea de vehículo';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de la línea';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdconc
			(c1,c2) 
		values(
			cve_consecionario,descripcion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdconc
			set c2=descripcion 
			where c1=cve_consecionario;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.conc
			where c1=cve_consecionario;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_consecionario;
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
