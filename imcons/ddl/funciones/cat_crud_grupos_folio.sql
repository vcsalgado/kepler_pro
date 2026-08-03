CREATE OR REPLACE FUNCTION keplersc.cat_crud_grupos_folio(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo kdgruposfolio
--Autor: Gad Miranda
--Fecha: 01/02/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucn text = '';
	cve_grupo_folio text = '';
	folio_sig int;
	descripcion text = '';

	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 

	sucn := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	cve_grupo_folio := (xpath('//document/k_clave/text()', dataxml))[1];
	folio_sig := (xpath('//document/k_folio/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_grupo_folio is null then 
			raise exception 'Debe seleccionar un Grupo Folio';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de Grupo Folio';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdgruposfolio
			(c1,c2,c3,c4) 
		values(
			sucn,cve_grupo_folio,folio_sig,descripcion);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdgruposfolio
			set c3=folio_sig, c4=descripcion
			where c1=sucn and c2=cve_grupo_folio;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdgruposfolio
			where c1=sucn and c2=cve_grupo_folio;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_grupo_folio;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_grupos_folio() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
