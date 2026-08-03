CREATE OR REPLACE FUNCTION keplersc.cat_crud_tmkt(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Crud Asesores TMKT
--Autor: Luis Leal
--Fecha: 27/05/2024
--Bitacora de cambios
declare
	--Variables de definicion de documento
    suc text = '';
	clave text = '';
    nombre text = '';
   	estatus text = '';
    correo text = '';
    tel_1 text = '';
    tel_2 text = '';
   	ext text = '';
	crud text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
    suc := (xpath('//document/sucursal_id/text()', dataxml))[1];
	clave := (xpath('//document/k_clave/text()', dataxml))[1];
	nombre := (xpath('//document/k_nombre/text()', dataxml))[1];
	estatus :=  (xpath('//document/k_estatus/text()', dataxml))[1];
   	correo := coalesce((xpath('//document/k_correo/text()', dataxml))[1],'');
	tel_1 := coalesce((xpath('//document/k_tel_1/text()', dataxml))[1],'');
	tel_2 := coalesce((xpath('//document/k_tel_2/text()', dataxml))[1],'');
	ext := coalesce((xpath('//document/k_ext/text()', dataxml))[1],'');
	crud := (xpath('//document/input_crud/text()', dataxml))[1];

	if crud = 'NUEVO' then
		insert into keplersc.kdsercattmkt  
			(c1,c2,c3,c4,c5,c6,c7,col_sucursal) 
		values(clave,nombre,estatus,correo,tel_1,tel_2,ext,suc);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdsercattmkt
			set c2=nombre,c3=estatus,c4=correo,c5=tel_1,c6=tel_2,c7=ext
			where col_sucursal=suc and c1=clave;
	end if;


	resultado := 1;
	mensaje := 'Registro agregado:' || clave;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_tmkt() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
