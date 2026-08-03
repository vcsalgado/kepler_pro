CREATE OR REPLACE FUNCTION keplersc.control_puntos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: control puntos
--Autor: Luis Leal
--Fecha: 19/07/2022
--Bitacora de cambios
declare

		sucursal_id text;
		folio_orden text;
		tipo_orden text;
		vin text;
	
		tipo_punto text;
		estatus text;
		clave_operario text;
		tipo_operario text;
		no_puntos int;
		numero_punto int;	
		ctd_puntos int;
		codigo_suspension text;
	
		estatus_previo text;
		ope_anterior text;
		cerrado_tabulacion text;
	
		ctd_puntos_pendientes int = 0;
		ctd_puntos_activos int = 0;
		ctd_puntos_suspendidos int = 0;
		ctd_puntos_terminados int = 0;
		ctd_total_puntos int = 0;
	
		flujo_admon numeric;
		flujo_servicio numeric = 0;

		get_resultado text;
		get_mensaje text; 
		get_adicionales text;
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
		folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text;
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	vin := coalesce((xpath('//document/vin/text()', dataxml))[1]::text,'')::text; 
	 
	 	select c7::numeric into flujo_admon from keplersc.kdord where c1=sucursal_id and c2=tipo_orden and c3= folio_orden;
	 
	 	if flujo_admon <> 0 then 
	 		raise exception '%' , 'Esta Orden ya no se encuentra abierta, no puedes modificar sus puntos';
	 	end if;
	 	
		strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
		no_puntos := strValor::integer;	
		ctd_puntos = no_puntos;
			
		for cont in 0..no_puntos - 1 loop
			numero_punto := cont + 1;
		
			tipo_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_punto/text()',dataxml))[1]::text,'');
			estatus := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/estatus/text()',dataxml))[1]::text,'');
			clave_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_operario/text()',dataxml))[1]::text,'');
			tipo_operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_operario/text()',dataxml))[1]::text,'');
			codigo_suspension := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/codigo_suspension/text()',dataxml))[1]::text,'');
		
			select c7, c22 into estatus_previo, cerrado_tabulacion from keplersc.kdpun 
			where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto; 
		
			if estatus <> 'T' and estatus_previo = 'T' and cerrado_tabulacion =  'C' then 
				raise exception '%', format('No se puede cambiar el estatus del punto %1$s , Ya esta cerrado en Tabulacion.', numero_punto);
			end if;
		
			--TODO, descomentar cuando se migre tabla
			/*select c9 into ope_anterior from keplersc.kdhoras where c1=sucursal_id
			and c2=tipo_orden and c3=folio_orden and c4=numero_punto limit 1; 
			if found then	
				if ope_anterior <> clave_operario then
					raise exception '%', format('Imposible hacer el cambio de operario porque el punto numero %1$s ya tiene horas cargadas al operario anterior.', numero_punto);
				end if;
			end if;*/
				
			update keplersc.kdpun set c7=estatus, c9=clave_operario,c17=codigo_suspension, c37=tipo_operario
			where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto; 
	
		end loop ;
	
		for estatus in select c7 from keplersc.kdpun where c1=sucursal_id 
		and c2=tipo_orden and c3=folio_orden 
		loop
			if estatus = 'P' then
				ctd_puntos_pendientes := ctd_puntos_pendientes + 1;
			end if;
			if estatus = 'A' then
				ctd_puntos_activos := ctd_puntos_activos + 1;
			end if;
			if estatus = 'S' then
				ctd_puntos_suspendidos := ctd_puntos_suspendidos + 1;
			end if;
			if estatus = 'T' then
				ctd_puntos_terminados := ctd_puntos_terminados + 1;
			end if;
			
			ctd_total_puntos := ctd_total_puntos + 1 ;
		end loop;
		
		if ctd_puntos_terminados = ctd_total_puntos then
			flujo_servicio := 30;
		end if;

		if ctd_puntos_activos > 0 then
			flujo_servicio := 10;
		else
			if ctd_puntos_suspendidos > 0 then
				flujo_servicio := 20;
			else
				if ctd_puntos_pendientes > 0 then
					flujo_servicio := 0;
				end if;
			end if;
		end if;
			
		update keplersc.kdord set c8=flujo_servicio where c1=sucursal_id and c2=tipo_orden and c3=folio_orden ; 
		
		resultado := 1;
		mensaje := 'Puntos Modificados';
		adicionales := folio_orden;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'control_puntos() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
