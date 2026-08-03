CREATE OR REPLACE FUNCTION keplersc.ser_iniciar_trabajo(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: iniciar trabajo 
--Autor: Luis Leal
--Fecha: 12/08/2022
--Bitacora de cambios
--27/05/2024 Miriam Santana: Grabar en kdpunres c17(usuario_operario) y c20(clave_operario)
declare
		sucursal_id text;
		tipo_orden text;
		folio_orden text;
		numero_punto text;
		clave_operario text;
		usuario_operario text;
		status_recomendacion text;
		consecutivo int;
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text; 
	 	numero_punto := coalesce((xpath('//document/numero_punto/text()', dataxml))[1]::text,'')::text; 
	 	clave_operario := coalesce((xpath('//document/clave_operario/text()', dataxml))[1]::text,'')::text;
	 	usuario_operario := coalesce((xpath('//document/usuario_operario/text()', dataxml))[1]::text,'')::text;	 
--	 	clave_operario:='';
--	 	usuario_operario:='';
	 	if numero_punto = '' then
	 		raise exception '%' , 'Debes seleccionar un punto';
	 	end if;
--raise notice 'clave_operario %, usuario_operario %',clave_operario, usuario_operario;	

		select c5 into status_recomendacion from  keplersc.kdpunres 
		where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
		if found then 
			update keplersc.kdpunres set c5=10 where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
		else
			insert into keplersc.kdpunres(c1,c2,c3,c4,c5,c6,c7,c17,c20) values(sucursal_id,tipo_orden,
			folio_orden,numero_punto::numeric,10, current_date, left(current_time::text,8),usuario_operario,clave_operario);
		end if;
	
		--registra tiempos 
		select c5::int into consecutivo from keplersc.kdtiempos where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric order by c5 desc limit 1;
		if found then
			consecutivo := consecutivo + 1 ;
		else
			consecutivo := 1;
		end if;
	
		insert into keplersc.kdtiempos(c1,c2,c3,c4,c5,c6,c7,c11,c12) values(sucursal_id,tipo_orden,
		folio_orden,numero_punto::numeric,consecutivo, current_date, left(current_time::text,8),usuario_operario,clave_operario);
	
		resultado := 1;
		mensaje :=  format('Trabajo numero %1$s iniciado', numero_punto );
		adicionales := folio_orden ;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_iniciar_trabajo() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
