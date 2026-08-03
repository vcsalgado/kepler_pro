CREATE OR REPLACE FUNCTION keplersc.ser_terminar_trabajo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: terminar trabajo 
--Autor: Luis Leal
--Fecha: 15/08/2022
--Bitacora de cambios
--27/05/2024 Miriam Santana: Incluir recomendaciones del tecnico al Terminar Trabajo
declare
		sucursal_id text;
		tipo_orden text;
		folio_orden text;
		numero_punto text;
		resultados text;
		recomendaciones text;
		clave_operario text;
		consecutivo int;
		minutos_transcurridos numeric;	
		mins_efectivos_transcurridos numeric;
		timestamp_inicial text; 
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text; 
	 	numero_punto := coalesce((xpath('//document/numero_punto/text()', dataxml))[1]::text,'')::text;
	 	resultados := coalesce((xpath('//document/resultados/text()', dataxml))[1]::text,'')::text;
	 	clave_operario := coalesce((xpath('//document/clave_operario/text()', dataxml))[1]::text,'')::text;
	 	recomendaciones := coalesce((xpath('//document/recomendaciones/text()', dataxml))[1]::text,'')::text;
	 	 
	 	if numero_punto = '' then
	 		raise exception '%' , 'Debes seleccionar un punto';
	 	end if;
	 
	 	if resultados = '' then
	 		raise exception '%' , 'Los RESULTADOS del trabajo deben ser ingresados, son obligatorios.';
	 	end if;

		select c5::int, concat(c6::date,' ',c7) into consecutivo,timestamp_inicial from keplersc.kdtiempos
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric order by c5 desc limit 1;
	
		select extract ( epoch from ( left(current_timestamp::text, 19)::timestamp  - timestamp_inicial::timestamp )   ) /60 into minutos_transcurridos;

		update keplersc.kdtiempos set c10=minutos_transcurridos, c8=current_date, c9=left(current_time::text,8)
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric and c5=consecutivo;
	
		select sum(c10) into mins_efectivos_transcurridos  from keplersc.kdtiempos
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
	
		select concat(c6::date,' ', c7) into timestamp_inicial from keplersc.kdpunres where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
		
		select extract ( epoch from ( left(current_timestamp::text, 19)::timestamp  - timestamp_inicial::timestamp )   ) /60 into minutos_transcurridos;
	
		update keplersc.kdpunres set c5=20,c8=current_date, c9=left(current_time::text,8), c10=minutos_transcurridos::numeric ,
			c11=resultados, c19= mins_efectivos_transcurridos, c33=recomendaciones 
			where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
	
		
		resultado := 1;
		mensaje := format('Trabajo numero %1$s terminado', numero_punto );
		adicionales := folio_orden ;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_terminar_trabajo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
