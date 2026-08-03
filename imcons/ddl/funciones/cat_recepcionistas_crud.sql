CREATE OR REPLACE FUNCTION keplersc.cat_recepcionistas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de líneas KDRECEP
--Autor: Jose Mendoza
--Fecha: 31/01/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_recep text = '';
	nombre text = '';

	k_activo text = '';
	k_usuario text = '';
	k_dir text = '';
	k_col text = '';
	k_pobl text = '';
	k_telofic text = '';
	k_telext text = '';
	k_celofic text = '';
	k_telcasa text = '';
	k_celpers text = '';
	k_sch_comis text = '';
	k_sch_utils text = '';
	k_hr1_ini text = '';
	k_hr1_fin text = '';
	k_hr2_ini text = '';
	k_hr2_fin text = '';
	k_comms1 text = '';
	k_comms2 text = '';
	k_comms3 text = '';

	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_recep := (xpath('//document/k_clave/text()', dataxml))[1];
	nombre := coalesce((xpath('//document/k_nombre/text()', dataxml))[1],'');

	k_activo := coalesce((xpath('//document/k_activo/text()', dataxml))[1],'');
	k_usuario := coalesce((xpath('//document/k_usuario/text()', dataxml))[1],'');
	k_dir := coalesce((xpath('//document/k_dir/text()', dataxml))[1],'');
	k_col := coalesce((xpath('//document/k_col/text()', dataxml))[1],'');
	k_pobl := coalesce((xpath('//document/k_pobl/text()', dataxml))[1],'');
	k_telofic := coalesce((xpath('//document/k_telofic/text()', dataxml))[1],'');
	k_telext := coalesce((xpath('//document/k_telext/text()', dataxml))[1],'');
	k_celofic := coalesce((xpath('//document/k_celofic/text()', dataxml))[1],'');
	k_telcasa := coalesce((xpath('//document/k_telcasa/text()', dataxml))[1],'');
	k_celpers := coalesce((xpath('//document/k_celpers/text()', dataxml))[1],'');
	k_sch_comis := coalesce((xpath('//document/k_sch_comis/text()', dataxml))[1],'');
	k_sch_utils := coalesce((xpath('//document/k_sch_utils/text()', dataxml))[1],'');
	k_hr1_ini := coalesce((xpath('//document/k_hr1_ini/text()', dataxml))[1],'');
	k_hr1_fin := coalesce((xpath('//document/k_hr1_fin/text()', dataxml))[1],'');
	k_hr2_ini := coalesce((xpath('//document/k_hr2_ini/text()', dataxml))[1],'');
	k_hr2_fin := coalesce((xpath('//document/k_hr2_fin/text()', dataxml))[1],'');
	k_comms1 := coalesce((xpath('//document/k_comms1/text()', dataxml))[1],'');
	k_comms2 := coalesce((xpath('//document/k_comms2/text()', dataxml))[1],'');
	k_comms3 := coalesce((xpath('//document/k_comms3/text()', dataxml))[1],'');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_recep is null then 
			raise exception 'Debe seleccionar una clave de recepcionista';
		end if;
		if nombre is null then 
			raise exception 'Debe ingresar el nombre del recepcionista';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdrecep  
			( c1,c2,c11,c12,c3,c4,c5,c8,c9,c10,c7,c20,c6,c18,c19,c13,c21,c14,c15,c16,c17 ) 
		values( cve_recep,nombre,k_activo,k_usuario,k_dir,k_col,k_pobl,k_comms1,k_comms2,k_comms3
			,k_telofic,k_telext,k_celofic,k_telcasa,k_celpers,k_sch_comis 
			,k_sch_utils::numeric,k_hr1_ini::numeric,k_hr1_fin::numeric,k_hr2_ini::numeric,k_hr2_fin::numeric );
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdrecep
		set c2 = nombre, c11 = k_activo, c12 = k_usuario, c3 = k_dir, c4 = k_col, c5 = k_pobl 
		, c8 = k_comms1, c9 = k_comms2, c10 = k_comms3, c7 = k_telofic, c20 = k_telext
		, c6 = k_celofic, c18 = k_telcasa, c19 = k_celpers, c13 = k_sch_comis, c21 = k_sch_utils::numeric 
		, c14 = k_hr1_ini::numeric, c15 = k_hr1_fin::numeric, c16 = k_hr2_ini::numeric, c17 = k_hr2_fin::numeric 
		where c1 = cve_recep;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.recep
			where c1 = cve_recep;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado : ' || cve_recep;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_recepcionistas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
