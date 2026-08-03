CREATE OR REPLACE FUNCTION keplersc.ubicacion_vehiculo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: actualiza ubicacion de vehiculo 
--Autor: Luis Leal
--Fecha: 12/08/2022
--Bitacora de cambios
declare
		sucursal_id text;
		vin text;
		ubicacion text;
		estatus int;
	
		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
	 	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	 	ubicacion := coalesce((xpath('//document/ubicacion/text()', dataxml))[1]::text,'')::text; 
	
	 	if vin = '' then
	 		raise exception '%' , 'Debe haber un Identificador.';
	 	end if;
	 
	 	if ubicacion = '' then
	 		raise exception '%' , 'Debes seleccionar la ubicación física del vehículo.';
	 	end if;
	 
	 	select c6::int into estatus from keplersc.kdvehqueue where c1=vin ;
	 	if found then 
	 	
	 		if ubicacion = 'F' and estatus <> 2 then
				raise exception '%' , 'No puede establecer que un vehículo esta fuera de taller si éste no está suspendido.';
			end if;
		
			update keplersc.kdvehqueue set c11=ubicacion where c1=vin;
		
		else
			insert into keplersc.kdvehqueue(c1,c3,c4,c11) values(vin,current_date, left(current_time::text,8), ubicacion);
	 	end if;
	 
	 	
		resultado := 1;
		mensaje := 'Ubicacion Actualizada';
		adicionales := vin;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ubicacion_vehiculo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
