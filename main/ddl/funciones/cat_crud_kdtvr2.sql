CREATE OR REPLACE FUNCTION keplersc.cat_crud_kdtvr2(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud kdtvr2
--Autor: Gad Miranda
--Fecha: 18/09/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_n_parte_crud text = ''; 
	k_desc_crud text = ''; 
	k_clas_mov_crud text = '';  
	k_cod_accesorio_crud text = '';  
	k_costo_dist_crud numeric(15,2); 
	k_precio_mayoreo_crud numeric(15,2); 
	k_precio_publico_crud numeric(15,2); 
	k_cantidad_unidad_crud numeric(5);
	k_cargo_pieza_remanu_crud numeric(8); 
	k_camb_precio_vol_crud text = '';
	k_no_usado_crud text = '';
	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';

	contador INT = 1;
	total_registros int;

begin 
	
	k_n_parte_crud := (xpath('//document/k_n_parte_crud/text()', dataxml))[1];
	k_desc_crud := (xpath('//document/k_desc_crud/text()', dataxml))[1];
	k_clas_mov_crud := (xpath('//document/k_clas_mov_crud/text()', dataxml))[1];
	k_cod_accesorio_crud := (xpath('//document/k_cod_accesorio_crud/text()', dataxml))[1];
	k_costo_dist_crud := (xpath('//document/k_costo_dist_crud/text()', dataxml))[1];
	k_precio_mayoreo_crud := (xpath('//document/k_precio_mayoreo_crud/text()', dataxml))[1];
	k_precio_publico_crud := (xpath('//document/k_precio_publico_crud/text()', dataxml))[1];
	k_cantidad_unidad_crud := (xpath('//document/k_cantidad_unidad_crud/text()', dataxml))[1];
	k_cargo_pieza_remanu_crud := (xpath('//document/k_cargo_pieza_remanu_crud/text()', dataxml))[1];
	k_camb_precio_vol_crud := (xpath('//document/k_camb_precio_vol_crud/text()', dataxml))[1];
	k_no_usado_crud := (xpath('//document/k_no_usado_crud/text()', dataxml))[1];

	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud = 'NUEVO' then
	select count(*) into totReg from keplersc.kdtvr2 where c1=k_n_parte_crud;
		if totReg > 0 then
			raise exception 'Error, El registro ya existe';
		end if;
		insert into keplersc.kdtvr2
			(c1,c2,c3, c4, c5, c6, c7, c8, c9, c10, c11, c12) 
		values(	k_n_parte_crud,'',k_desc_crud,k_clas_mov_crud
		,k_cod_accesorio_crud,k_costo_dist_crud,k_precio_mayoreo_crud
		,k_precio_publico_crud,k_cantidad_unidad_crud,k_cargo_pieza_remanu_crud
		,k_camb_precio_vol_crud,k_no_usado_crud);
	
	end if;


	if crud = 'MODIFICAR' then
		update keplersc.kdtvr2 
			set c2=''
			, c3 = k_desc_crud
			, c4 = k_clas_mov_crud
			, c5 = k_cod_accesorio_crud
			, c6 = k_costo_dist_crud
			, c7 = k_precio_mayoreo_crud
			, c8 = k_precio_publico_crud
			, c9 = k_cantidad_unidad_crud
			, c10 = k_cargo_pieza_remanu_crud
			, c11 = k_camb_precio_vol_crud
			, c12 = k_no_usado_crud
			where c1=k_n_parte_crud;
	end if;
end;
$function$
