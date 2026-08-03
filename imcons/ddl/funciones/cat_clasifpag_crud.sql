CREATE OR REPLACE FUNCTION keplersc.cat_clasifpag_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de líneas KDRECEP
--Autor: Jose Mendoza
--Fecha: 02/02/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	cve_clas text = '';
	descrip text = '';

	k_base_hrs text = '';
	k_base_sueldo text = '';
	k_p_nor text = '';
	k_p_gar text = '';
	k_p_int text = '';
	k_p_pre text = '';
	k_p_rec text = '';
	k_tarifa1 text = '';
	k_escalon1 text = '';
	k_tarifa2 text = '';
	k_escalon2 text = '';
	k_tarifa3 text = '';
	k_escalon3 text = '';
	k_tarifa4 text = '';

	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	cve_clas := (xpath('//document/k_clave/text()', dataxml))[1];
	descrip := coalesce((xpath('//document/k_descrip/text()', dataxml))[1],'');
	
	k_base_hrs := coalesce((xpath('//document/k_base_hrs/text()', dataxml))[1],'');
	k_base_sueldo := coalesce((xpath('//document/k_base_sueldo/text()', dataxml))[1],'');

	k_p_nor := coalesce((xpath('//document/k_p_nor/text()', dataxml))[1],'');
	k_p_gar := coalesce((xpath('//document/k_p_gar/text()', dataxml))[1],'');
	k_p_int := coalesce((xpath('//document/k_p_int/text()', dataxml))[1],'');
	k_p_pre := coalesce((xpath('//document/k_p_pre/text()', dataxml))[1],'');
	k_p_rec := coalesce((xpath('//document/k_p_rec/text()', dataxml))[1],'');

	k_tarifa1 := coalesce((xpath('//document/k_tarifa1/text()', dataxml))[1],'');
	k_escalon1 := coalesce((xpath('//document/k_escalon1/text()', dataxml))[1],'');
	k_tarifa2 := coalesce((xpath('//document/k_tarifa2/text()', dataxml))[1],'');
	k_escalon2 := coalesce((xpath('//document/k_escalon2/text()', dataxml))[1],'');
	k_tarifa3 := coalesce((xpath('//document/k_tarifa3/text()', dataxml))[1],'');
	k_escalon3 := coalesce((xpath('//document/k_escalon3/text()', dataxml))[1],'');
	k_tarifa4 := coalesce((xpath('//document/k_tarifa4/text()', dataxml))[1],'');
	
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud <> 'ELIMINAR' then
		if cve_clas is null then 
			raise exception 'Debe seleccionar una clave de recepcionista';
		end if;
		if descrip is null then 
			raise exception 'Debe ingresar el nombre del recepcionista';
		end if;
	end if; 

	if crud = 'NUEVO' then
		insert into keplersc.kdclaspag   
			( c1,c2,c3,c5
			 ,c6,c7,c8,c9,c10
			 ,c4,c11,c12,c13,c14,c15,c16) 
		values( cve_clas,descrip,k_base_hrs::numeric,k_base_sueldo::numeric
			,k_p_nor::numeric,k_p_gar::numeric,k_p_int::numeric,k_p_pre::numeric,k_p_rec::numeric
			,k_tarifa1::numeric,k_escalon1::numeric,k_tarifa2::numeric,k_escalon2::numeric
			,k_tarifa3::numeric,k_escalon3::numeric,k_tarifa4::numeric );
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdclaspag 
		set c2 = descrip, c3 = k_base_hrs::numeric, c5 = k_base_sueldo::numeric
		, c6 = k_p_nor::numeric, c7 = k_p_gar::numeric, c8 = k_p_int::numeric
		, c9 = k_p_pre::numeric, c10 = k_p_rec::numeric
		, c4 = k_tarifa1::numeric, c11 = k_escalon1::numeric, c12 = k_tarifa2::numeric, c13 = k_escalon2::numeric
		, c14 = k_tarifa3::numeric, c15 = k_escalon3::numeric, c16 = k_tarifa4::numeric		
		where c1 = cve_clas;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.kdclaspag 
			where c1 = cve_clas;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado : ' || cve_clas;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_clasif_pagos_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
