CREATE OR REPLACE FUNCTION keplersc.cat_crud_sucursal(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de sucursales
--Autor: Gad Miranda
--Fecha: 04/07/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_clave_suc_crud text = '';
	k_nom_suc_crud text = '';
	k_id_suc_crud text = '';
	k_lugar_exp_crud text = '';
	k_clave_distri_crud text = '';
	k_c6 text = '';
	k_c7 text = '';
	k_c8 text = '';
	k_c9 text = '';
	k_c10 text = '';
	k_c11 text = '';
	k_c12 text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_clave_suc_crud := (xpath('//document/k_clave_suc_crud/text()', dataxml))[1];
	k_nom_suc_crud := (xpath('//document/k_nom_suc_crud/text()', dataxml))[1];
	k_id_suc_crud := (xpath('//document/k_id_suc_crud/text()', dataxml))[1];
	k_lugar_exp_crud := (xpath('//document/k_lugar_exp_crud/text()', dataxml))[1];
	k_clave_distri_crud := coalesce((xpath('//document/k_clave_distri_crud/text()', dataxml))[1], '');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdms where c1=k_clave_suc_crud ;
			if totReg > 0 then
   				raise exception 'Error, La clave de sucursal ya existe';
			end if;

		insert into keplersc.kdms
			(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) 
		values(	k_clave_suc_crud,k_nom_suc_crud,k_id_suc_crud,k_lugar_exp_crud,k_clave_distri_crud
		,k_c6,k_c7,k_c8,k_c9,k_c10,k_c11,k_c12);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdms as n
			set c2=k_nom_suc_crud,
			c3=k_id_suc_crud,
			c4=k_lugar_exp_crud,
			c5=k_clave_distri_crud,
			c6=k_c6,
			c7=k_c7,
			c8=k_c8,
			c9=k_c9,
			c10=k_c10,
			c11=k_c11,
			c12=k_c12
			where c1=k_clave_suc_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdms
			where  c1=k_clave_suc_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_clave_suc_crud  || k_id_suc_crud;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_sucursal() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
