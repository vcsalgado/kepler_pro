CREATE OR REPLACE FUNCTION keplersc.cat_esqasepaq_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de esquemas de comosiones por paquete de asesores
--Autor: Victor Salgado
--Fecha: 18/09/2025
--Bitacora de cambios
declare
	--Variables de definicion de documento
    k_clave text = '';
	k_porcentaje_actual numeric = 0;
	k_porcentaje_nuevo numeric = 0;

	no_partidas int = 0;
	strValor text = '';

   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	--Elimina registros de tabla
	delete from keplersc.kdesqasepaq;

	for cont in 0..no_partidas loop
		
		k_clave := coalesce((xpath('//document/k_mov/r' ||cont||'/k_clave/text()',dataxml))[1],'');
		strValor := coalesce((xpath('//document/k_mov/r' ||cont||'/k_porcentaje_nuevo/text()',dataxml))[1],'0');
		k_porcentaje_nuevo:= strValor::numeric;
--raise exception 'k_clave %; k_porcentaje_nuevo %',k_clave, k_porcentaje_nuevo;
		if k_porcentaje_nuevo = 0 then 
			continue;
		end if;
		insert into keplersc.kdesqasepaq (c1,c2) values(k_clave,k_porcentaje_nuevo);
	end loop;

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
