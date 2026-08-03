CREATE OR REPLACE FUNCTION keplersc.cat_concepresup_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de conceptos de presupuesto KDCATCONPRES
--Autor: Miriam Santana
--Fecha: 11/07/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
	clave text = '';
	desc_concepto text = '';
	sucursal_id text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	clave := (xpath('//document/k_clave/text()', dataxml))[1];
	desc_concepto := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if clave is null then 
			raise exception 'Debe seleccionar una clave de concepto';
		end if;
		if desc_concepto is null then 
			raise exception 'Debe ingresar la descripci n del concepto';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdcatconpres
			(sucursal,cve_concepto,descripcion) 
		values(
			sucursal_id,clave,desc_concepto);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdcatconpres
			set descripcion=desc_concepto 
			where sucursal=sucursal_id and cve_concepto=clave;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdcatconpres
			where sucursal=sucursal_id and cve_concepto=clave;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || clave;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_concepresup_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
