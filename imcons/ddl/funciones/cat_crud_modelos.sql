CREATE OR REPLACE FUNCTION keplersc.cat_crud_modelos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo Modelos
--Autor: Gad Miranda
--Fecha: 01/02/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
    cve_marca text = '';
	cve_modelo text = '';
	descripcion text = '';
    tipo_vei text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
    cve_marca := (xpath('//document/k_marca/r1/text()', dataxml))[1];
	cve_modelo := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
    tipo_vei := (xpath('//document/k_tipo_vei/r1/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_modelo is null then 
			raise exception 'Debe seleccionar una línea de vehículo';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de la línea';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdmodelos  
			(c1,c2,c3,c4,c5) 
		values(
			cve_marca,cve_modelo,descripcion,tipo_vei,'');
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdmodelos
			set c3=descripcion, c4=tipo_vei
			where c1=cve_marca and c2=cve_modelo;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdmodelos
			where c1=cve_marca and c2 =cve_modelo;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_modelo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_modelos() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
