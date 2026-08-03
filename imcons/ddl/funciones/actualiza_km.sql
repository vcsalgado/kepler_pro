CREATE OR REPLACE FUNCTION keplersc.actualiza_km(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza actualizacion del kilometraje en kdserie, kdvntall y el registro en kdusraccess
--Autor: Gad Miranda
--Fecha: 24/01/2024
--Bitacora de cambios
--23/09/2024 Miriam Santana: Actualizar unicamente un solo registro que corresponda al ultimo folio registrado y guarde correctamente en kdusraccess el ultimo km
declare
	--Variables de definicion de documento
    v_usuario VARCHAR(255);	
 	v_fecha_actual DATE; 
 	v_hora_actual VARCHAR(8);
    v_sucursal VARCHAR(255);
    v_serie VARCHAR(255);
    v_km_anterior NUMERIC;
    v_km_nuevo NUMERIC;
  	v_km_actual NUMERIC;
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
   
   	folio text ='';
	
begin 
	
	v_serie := (xpath('//document/k_serie/text()', dataxml))[1];
	v_km_nuevo := (xpath('//document/k_nuevo_km_reg/text()', dataxml))[1];
	v_km_actual := (xpath('//document/k_ult_km_reg/text()', dataxml))[1];		 

	v_usuario := (xpath('//document/k_usuario/text()', dataxml))[1];
  	v_sucursal := (xpath('//document/k_sucursal/text()', dataxml))[1];
  	
  	v_fecha_actual := current_date;
  	v_hora_actual := left(current_time::text, 8);

	UPDATE keplersc.kdserie SET c12 = v_km_nuevo WHERE c1 = v_serie;

	--MSS 23092024
	select c10 into folio from keplersc.kdvntall k 	
		where C14= v_serie order by c11 desc limit 1;
	
	UPDATE keplersc.kdvntall SET c17 = v_km_nuevo WHERE c14 = v_serie and c10 = folio;		--MSS 23092024 Actualice ultimo folio registrado

	INSERT INTO keplersc.kdusraccess (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10,c11)
  	VALUES (v_usuario, v_fecha_actual, v_hora_actual, v_sucursal, '', '', 0, 0, v_serie,'Camb_km', 'KM anterior ' || v_km_actual || ', Km nuevo: ' || v_km_nuevo);

	resultado := 1;
	mensaje := 'Registro agregado:' || v_serie;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'actualiza_km() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
