CREATE OR REPLACE FUNCTION keplersc.ser_autoriza_cierre_orden(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: autoriza cierre orden 
--Autor: Luis Leal
--Fecha: 03/11/2022
--Bitacora de cambios
declare
		sucursal_id text;
		folio_orden text;
		tipo_orden text;
		usuario_autorizando text;
		comentarios text;
		ctd_cierre_calidad numeric;

		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
		tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
		folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text;
	  	usuario_autorizando  := ((xpath('//document/k_usuario_autorizando/text()', dataxml))[1]::text)::text; 
	  	comentarios := coalesce((xpath('//document/k_comment/text()', dataxml))[1]::text,'')::text;

	  	select count(*) into ctd_cierre_calidad from keplersc.kdscierrecalidad where c1= sucursal_id and c2=tipo_orden and c3=folio_orden;

	  	if ctd_cierre_calidad = 0 then
			insert into keplersc.kdscierrecalidad(c1,c2,c3,c5,c6,c7,c8)values (sucursal_id, tipo_orden, 
			folio_orden, current_date,	left(current_time::text, 8), usuario_autorizando , comentarios);
			mensaje := 'Cierre Autorizado';
		else 
			mensaje := 'El Cierre de esta Orden ya esta Autorizado';
		end if;
		
		resultado := 1;
		adicionales := folio_orden;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_autoriza_cierre_orden() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
