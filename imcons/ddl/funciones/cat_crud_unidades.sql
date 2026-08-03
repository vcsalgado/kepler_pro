CREATE OR REPLACE FUNCTION keplersc.cat_crud_unidades(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de Unidades
--Autor: Gad Miranda
--Fecha: 07/07/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_unidad_crud text = '';
	k_desc_unidad_crud text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_unidad_crud := (xpath('//document/k_unidad_crud/text()', dataxml))[1];
	k_desc_unidad_crud := (xpath('//document/k_desc_unidad_crud/text()', dataxml))[1];

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdinu where c1=k_unidad_crud ;
			if totReg > 0 then
   				raise exception 'Error, El registro ya existe';
			end if;

		insert into keplersc.kdinu
			(c1,c2) 
		values(	k_unidad_crud,k_desc_unidad_crud);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdinu as n
			set  c2=k_desc_unidad_crud
			where c1=k_unidad_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdinu
			where  c1=k_unidad_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_unidad_crud || k_desc_unidad_crud;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_unidades() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
