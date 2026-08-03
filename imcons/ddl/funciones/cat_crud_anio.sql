CREATE OR REPLACE FUNCTION keplersc.cat_crud_anio(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de anio
--Autor: Gad Miranda
--Fecha: 19/06/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_anio_crud text = '';
	k_desc_anio_crud text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_anio_crud := (xpath('//document/k_anio_crud/text()', dataxml))[1];
	k_desc_anio_crud := (xpath('//document/k_desc_anio_crud/text()', dataxml))[1];

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdanio where c1=k_anio_crud ;
			if totReg > 0 then
   				raise exception 'Error, El registro ya existe';
			end if;

		insert into keplersc.kdanio
			(c1,c2) 
		values(	k_anio_crud,k_desc_anio_crud);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdanio as n
			set  c2=k_desc_anio_crud
			where c1=k_anio_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.anio
			where  c1=k_anio_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_anio_crud ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_anio() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
