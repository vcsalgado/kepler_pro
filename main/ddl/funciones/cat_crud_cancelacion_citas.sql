CREATE OR REPLACE FUNCTION keplersc.cat_crud_cancelacion_citas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de motivos de cancelaciones de citas
--Autor: Gad Miranda
--Fecha: 07/07/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_clave_crud text = '';
	k_desc_crud text = '';
	k_estatus_crud text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_clave_crud := (xpath('//document/k_clave_crud/text()', dataxml))[1];
	k_desc_crud := (xpath('//document/k_desc_crud/text()', dataxml))[1];
	k_estatus_crud := (xpath('//document/k_estatus_crud/r1/text()', dataxml))[1];

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdmotivoscancelacioncitas where c1=k_clave_crud ;
			if totReg > 0 then
   				raise exception 'Error, El registro ya existe';
			end if;

		insert into keplersc.kdmotivoscancelacioncitas
			(c1,c2,c3) 
		values(	k_clave_crud,k_desc_crud,k_estatus_crud);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdmotivoscancelacioncitas as n
			set  c2=k_desc_crud , c3=k_estatus_crud
			where c1=k_clave_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdmotivoscancelacioncitas
			where  c1=k_clave_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_clave_crud || k_desc_crud;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_motivos_cancelacion_citas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
