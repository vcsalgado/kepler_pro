CREATE OR REPLACE FUNCTION keplersc.cat_esqasepun_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de esquemas de asesores
--Autor: Victor Salgado
--Fecha: 25/08/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
    k_tipo text = '';
	k_util_1 text = '';
	k_por_1 text = '';
    k_util_2 text = '';
	k_por_2 text = '';
    k_util_3 text = '';
	k_por_3 text = '';
    k_util_4 text = '';
	k_por_4 text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
    k_tipo := (xpath('//document/cmb_tipo/r1/text()', dataxml))[1];
	k_util_1 := (xpath('//document/k_util_1/text()', dataxml))[1];
	k_por_1 := coalesce((xpath('//document/k_por_1/text()', dataxml))[1],'');
	k_util_2 := (xpath('//document/k_util_2/text()', dataxml))[1];
	k_por_2 := coalesce((xpath('//document/k_por_2/text()', dataxml))[1],'');
	k_util_3 := (xpath('//document/k_util_3/text()', dataxml))[1];
	k_por_3 := coalesce((xpath('//document/k_por_3/text()', dataxml))[1],'');
	k_util_4 := (xpath('//document/k_util_4/text()', dataxml))[1];
	k_por_4 := coalesce((xpath('//document/k_por_4/text()', dataxml))[1],'');

	--Eliminar registros existentes
	delete from keplersc.kdesqasepun where c1=k_tipo;
	insert into keplersc.kdesqasepun  (c1,c2,c3,c4,c5,c6,c7,c8,c9) 
	values(k_tipo,k_util_1::numeric,k_por_1::numeric,k_util_2::numeric,k_por_2::numeric,k_util_3::numeric,k_por_3::numeric,k_util_4::numeric,k_por_4::numeric);

	resultado := 1;
	mensaje := 'Registro actualizado';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_esqasepun_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
