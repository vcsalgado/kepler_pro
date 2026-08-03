CREATE OR REPLACE FUNCTION keplersc.cat_notacargo_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de notas de cargo en  KDNCARGOCAT
--Autor: Miriam Santana
--Fecha: 25/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_ncargo text = '';
	cve_sat text = '';
	descripcion text = '';
	unidad text = '';
	crud text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_ncargo := (xpath('//document/k_clave/text()', dataxml))[1];
	cve_sat := (xpath('//document/k_sat/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	unidad := (xpath('//document/k_unidad/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_ncargo is null then 
			raise exception 'Debe seleccionar una clave de nota de cargo';
		end if;
		if cve_sat is null then 
			raise exception 'Debe ingresar la clave del SAT';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción';
		end if;
		if unidad is null then 
			raise exception 'Debe ingresar la unidad';
		end if;
	end if; 

	if crud = 'NUEVO' then		
		insert into keplersc.kdncargocat 
			(c1,c2,c3,c4) 
		values(
			cve_ncargo,cve_sat,descripcion,unidad);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdncargocat 
			set c2=cve_sat,
			c3=descripcion,
			c4=unidad
			where c1=cve_ncargo;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdncargocat k 
			where c1=cve_ncargo;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_ncargo;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_notacargo_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
