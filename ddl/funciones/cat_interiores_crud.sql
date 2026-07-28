CREATE OR REPLACE FUNCTION keplersc.cat_interiores_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de interiores KDICE3
--Autor: Miriam Santana
--Fecha: 24/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_modelo text = '';
	cve_color text = '';
	descripcion text = '';
	crud text = '';
	totReg int = 0;

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_modelo := (xpath('//document/k_modelo/text()', dataxml))[1];
	cve_color := (xpath('//document/k_color/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_modelo is null then 
			raise exception 'Debe seleccionar un modelo de vehículo';
		end if;
		if cve_color is null then 
			raise exception 'Debe ingresar la clave del color';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción del color';
		end if;
	end if; 

	if crud = 'NUEVO' then	
		select count(*) into totReg from keplersc.kdiv
			where c1=cve_modelo;
		if totReg > 0 then
			insert into keplersc.kdice3 
				(c1,c3,c4) 
			values(
				cve_modelo,cve_color,descripcion);
		else
			raise exception 'No existe el vehículo, es necesario darlo de alta';
		end if;	
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdice3  
			set c4=descripcion 
			where c1=cve_modelo and c3=cve_color;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdice3
			where c1=cve_modelo and c3=cve_color;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_modelo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_interiores_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
