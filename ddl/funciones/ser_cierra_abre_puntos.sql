CREATE OR REPLACE FUNCTION keplersc.ser_cierra_abre_puntos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cierra y abre puntos en tabulacion
--Autor: Luis Leal
--Fecha: 23/08/2022
--Bitacora de cambios
----Miriam Santana: 10/10/24: No permita modifcar puntos si la orden esta cerrada
declare

		sucursal_id text;
		folio_orden text;
		tipo_orden text;
		factor_conversion numeric;
	
		tipo_punto text;
		no_puntos int;
		numero_punto int;	
		operario text;
		horas text;
		tabulacion text;
		ctd_puntos int;
		estado_pago_ope numeric;
		estado_anterior_tab text;
	
		flujo_admon numeric;	--MSS
	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1]; 
		folio_orden := coalesce((xpath('//document/folio_orden/text()', dataxml))[1]::text,'')::text;
	 	tipo_orden := coalesce((xpath('//document/tipo_orden/text()', dataxml))[1]::text,'')::text; 
	 	
	 	--MSS 10102024: No permita modifcar puntos si la orden esta cerrada
	 	select c7::numeric into flujo_admon from keplersc.kdord where c1=sucursal_id and c2=tipo_orden and c3= folio_orden;	 
	 	if flujo_admon <> 0 then 
	 		raise exception '%' , 'Esta Orden ya no se encuentra abierta, no puedes modificar sus puntos';
	 	end if;
	 
	 	select c8::numeric into factor_conversion from keplersc.kdmargen where c1=tipo_orden;
	 	
		strValor := (xpath('//document/ctd_puntos/text()',dataxml))[1];
		no_puntos := strValor::integer;	
		ctd_puntos = no_puntos;
			
		for cont in 0..no_puntos - 1 loop
			numero_punto := cont + 1;
		
			tipo_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tipo_punto/text()',dataxml))[1]::text,'');
			numero_punto := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/numero_punto/text()',dataxml))[1]::text,'');
			operario := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/clave_operario/text()',dataxml))[1]::text,'');
			horas :=  coalesce((xpath('//document/tabla_puntos/r' ||cont||'/horas/text()',dataxml))[1]::text,'');
			tabulacion := coalesce((xpath('//document/tabla_puntos/r' ||cont||'/tabulacion/text()',dataxml))[1]::text,'');
		
			select c22 into estado_anterior_tab from keplersc.kdpun where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
		
			if estado_anterior_tab <> tabulacion then
raise notice 'estado_anterior_tab:% tabulacion:%',estado_anterior_tab,tabulacion;			
				if tabulacion = 'C' then
				
					update keplersc.kdpun set c22='C', c28=left(current_time::text, 8),c33=current_date
					where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto; 
				
					update keplersc.kdhoras set c12=current_date, c13=left(current_time::text, 5), c15=factor_conversion, c16='C'
					where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
				
					insert into keplersc.kdhorpag (c1,c2,c3,c4,c11, c13, c14) values(sucursal_id, tipo_orden, folio_orden,
					numero_punto::numeric, current_date,operario,horas::numeric * factor_conversion );
				
				end if;
			
			
				if tabulacion = 'A' then
				
					if estado_anterior_tab <> 'C' then
						raise exception 'Imposible abrir punto número % porque no esta cerrado todavía.', numero_punto;
					end if;
						
					select c5::numeric into estado_pago_ope from keplersc.kdhorpag where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
raise notice 'If tab A sucursal_id:% tipo_orden:% folio_orden:% numero_punto:% estado_pago_ope:%',sucursal_id,tipo_orden,folio_orden,numero_punto,estado_pago_ope;				
					if estado_pago_ope is not null then 
						if estado_pago_ope > 0 then
							raise exception 'Imposible abrir punto número % porque ya fue pagado al operario ', numero_punto;
						else
							delete from keplersc.kdhorpag where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
					
							update keplersc.kdpun set c22='A', c28='',c33='1800-01-01'::date
							where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto; 
						
							update keplersc.kdhoras set c12='1800-01-01'::date, c13='', c15=0, c16='A'
							where c1=sucursal_id and c2=tipo_orden and c3=folio_orden and c4=numero_punto;
						end if;
					end if;
	
				end if;
			
			end if;

		
	
		end loop ;
		
		resultado := 1;
		mensaje := 'Puntos Modificados';
		adicionales := folio_orden;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_cierra_puntos() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
