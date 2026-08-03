CREATE OR REPLACE FUNCTION keplersc.cat_crud_paquetes(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de kdcatpaq
--Autor: Gad Miranda
--Fecha: 01/02/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_paquete text = '';
	descripcion text = '';
	clas_paquete text = '';
	clas_horas text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_paquete := (xpath('//document/k_clave/text()', dataxml))[1];
	descripcion := coalesce((xpath('//document/k_descripcion/text()', dataxml))[1],'');
	clas_paquete := (xpath('//document/k_clas_paquete/r0/text()', dataxml))[1];
	clas_horas := (xpath('//document/k_clas_horas/r0/text()', dataxml))[1];
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_paquete is null then 
			raise exception 'Debe seleccionar una paquete';
		end if;
		if descripcion is null then 
			raise exception 'Debe ingresar la descripción de paquete';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdcatpaq  
			(c1,c2,c3,c4) 
		values(
			cve_paquete,descripcion,clas_paquete,clas_horas);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdcatpaq
			set c2=descripcion,c3=clas_paquete,c4=clas_horas
			where c1=cve_paquete;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdcatpaq
			where c1=cve_paquete;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || cve_paquete;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_paguetes() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
