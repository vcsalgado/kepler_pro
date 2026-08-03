CREATE OR REPLACE FUNCTION keplersc.ser_cargar_horas(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: carga horas de puntos de servicio
--Autor: Luis Leal
--Fecha: 19/08/2022
--Bitacora de cambios
declare
		sucursal_id text;
		tipo_orden text;
		folio_orden text;
		numero_punto text;
		tipo_punto text;
		marca text;
		modelo text;
		clave_paquete text;
		descripcion_paquete text;
		pnt_seleccionado text;
		operario text;
		costo_por_hora numeric = 0;
		factor_conversion numeric = 0;
		iva numeric = 0;
		varios numeric;
		horas_paq numeric;
		precio_paq numeric;
		refacciones numeric;

		clave_horas text;	
		descripcion_horas text;
		horas text;

		problema text;
		causa text;
		correccion text;
		notas_cliente text;
		codigo_falla text;
		queja_cliente text;
		
		strValor text;
		no_horas int;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
	   
		iva_cte decimal = 0.00;		--cfdi no calculos
		total_cte decimal = 0.00;	--cfdi no calculos
		subtotal decimal = 0.00; --cfdi no calculos
		
		begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text; 
	 	numero_punto := coalesce((xpath('//document/numero_punto/text()', dataxml))[1]::text,'')::text; 
	 	tipo_punto := coalesce((xpath('//document/tipo_punto/text()', dataxml))[1]::text,'')::text; 
		marca := coalesce((xpath('//document/marca/text()', dataxml))[1]::text,'')::text; 
	 	modelo := coalesce((xpath('//document/modelo/text()', dataxml))[1]::text,'')::text; 
	 	clave_paquete := coalesce((xpath('//document/paquete/text()', dataxml))[1]::text,'')::text; 
	 	descripcion_paquete := coalesce((xpath('//document/descripcion_paquete/text()', dataxml))[1]::text,'')::text; 
	  	pnt_seleccionado := coalesce((xpath('//document/pnt_seleccionado/text()', dataxml))[1]::text,'')::text; 

	 	operario := coalesce((xpath('//document/operario/text()', dataxml))[1]::text,'')::text; 
	 	problema := coalesce((xpath('//document/problema/text()', dataxml))[1]::text,'')::text; 
	 	causa := coalesce((xpath('//document/causa/text()', dataxml))[1]::text,'')::text; 
	 	correccion := coalesce((xpath('//document/correccion/text()', dataxml))[1]::text,'')::text; 
	 	notas_cliente := coalesce((xpath('//document/notas_cliente/text()', dataxml))[1]::text,'')::text; 
	 	codigo_falla := coalesce((xpath('//document/codigo_falla/text()', dataxml))[1]::text,'')::text; 
	    queja_cliente := coalesce((xpath('//document/queja_cliente/text()', dataxml))[1]::text,'')::text; 
	   		
	   	if pnt_seleccionado = '' then
	   		raise exception '%', 'Debes seleccionar un punto al que cargarle horas';
	   	end if;
	   
	    update keplersc.kdpun set c9=operario,c10=codigo_falla,c11=queja_cliente,c12=problema,c13=causa,c14=correccion,c15=notas_cliente
	    where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;

	 	if tipo_punto <> 'L' then
	 	
	 		select c4::numeric,c8::numeric, c11::numeric into costo_por_hora, factor_conversion,iva from keplersc.kdmargen where c1=tipo_orden;
	 	
	 		--TODO, verificar si es correcto
	 		if tipo_punto = 'S' then
	 		
	 			delete from keplersc.kdcar where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
			
				select c8::numeric, c9::numeric, c10::numeric into varios,horas_paq, precio_paq 
				from keplersc.kdspaq where c1=marca and c2=modelo and c4=clave_paquete;
				
				--cfdi no cálculos
				iva_cte := 0; total_cte := 0;
				iva_cte := varios * (iva/100);
				total_cte := varios + iva_cte;
				--En el insert c11 y c12
				insert into keplersc.kdcar (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) values(sucursal_id, tipo_orden, folio_orden,
				numero_punto::numeric, 1,clave_paquete,descripcion_paquete, 0,100, varios,iva_cte,total_cte);
				
				select sum(c16) into refacciones from keplersc.kdref where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;
				if refacciones is null then 
					refacciones := 0;
				end if;
			
				costo_por_hora := (precio_paq /(1+(iva/100)))-varios-refacciones;
			
				if horas_paq > 0 then
					costo_por_hora := costo_por_hora/horas_paq;
				end if;
	 		
	 		end if;
	 	
	 	else
	 		costo_por_hora := 0;
		end if;
	
		delete from keplersc.kdhoras where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto::numeric;

		strValor := (xpath('//document/ctd_horas/text()',dataxml))[1];
	
		if strValor = '0' then
			raise exception '%', 'Debes agregar horas por cargar';
		end if ;
		
		no_horas := strValor::integer;	
		
		for cont in 0..no_horas - 1 loop
		
			clave_horas := coalesce((xpath('//document/tabla_horas/r' ||cont||'/clave_horas/text()',dataxml))[1]::text,'');
			descripcion_horas := coalesce((xpath('//document/tabla_horas/r' ||cont||'/descripcion_horas/text()',dataxml))[1]::text,'');
			horas := coalesce((xpath('//document/tabla_horas/r' ||cont||'/horas/text()',dataxml))[1]::text,'');
		
			if clave_horas = '' or descripcion_horas = '' or horas = '' then			
				--MSS: Enviar mensaje y no permitir grabar si estan vacios o <=0 las horas
				if clave_horas = '' then 
					raise exception 'Falta clave de horas en el punto: %', numero_punto;			
				end if;
				if descripcion_horas = '' then 
					raise exception 'Falta descripción de horas en el punto: %', numero_punto;			
				end if;
				if horas = '' then 
					raise exception 'Falta no. horas en el punto: %', numero_punto;			
				end if;
			else 
				if horas::numeric<=0 then
					raise exception 'El no. de horas no pueden ser 0 o negativo en el punto: %', numero_punto;	
				end if;
			end if;
		--cfdi no cálculos
			iva_cte := 0; subtotal := 0; total_cte := 0;
			subtotal := costo_por_hora*horas::numeric;
			-- 2dec subtotal := round(costo_por_hora,2)*horas::numeric;
		
			iva_cte := subtotal * (iva/100);
			total_cte := subtotal + iva_cte;

		--En el insert c17,c18 y c19
			insert into keplersc.kdhoras(c1,c2,c3,c4,c5,c6,c7,c8,c9,c14,c15,c16,c17,c18,c19) values(sucursal_id,tipo_orden,
			folio_orden,numero_punto::numeric, cont + 1, clave_horas, descripcion_horas, horas::numeric, operario, 
			costo_por_hora,factor_conversion,'A',subtotal,iva_cte,total_cte);			
		--raise notice 'horas:% costo_por_hora:% subtotal:% iva_cte:% total_cte:%',horas,costo_por_hora,subtotal,iva_cte,total_cte;

		end loop ;
	
		resultado := 1;
		mensaje :=  format('Horas cargadas para punto numero %1$s ', numero_punto );
		adicionales := folio_orden ;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_cargar_horas() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
