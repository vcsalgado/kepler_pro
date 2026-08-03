CREATE OR REPLACE FUNCTION keplersc.ser_cierra_abre_ord_cargos_tots_refs(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$

--Descripcion: Cierra y abre orden de Cargos varios, TOTS 
--Autor: Miriam Santana
--Fecha: 08/09/2022
--Bitacora de cambios
--Descripcion: Cierra y abre orden de Refacciones
--Autor: Luis Leal
--Fecha: 02/11/2022
declare
	--Variables de definicion de documento
	sucursal_id text;
	tipo_orden text;
	num_orden text;
	tipo_operacion text;
	tipo_opcion text;
	strValor text;
	fecha date;
	hora text;
	
	begin
		sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1];
		tipo_orden := (xpath('//document/k_tipo/text()', dataxml))[1]; 
		num_orden := (xpath('//document/k_folio/text()', dataxml))[1];
		tipo_operacion := (xpath('//document/k_tipo_ope/text()', dataxml))[1];
		tipo_opcion := (xpath('//document/k_tipo_opc/text()', dataxml))[1];
	raise notice '%','tipo_opcion: ' ||tipo_opcion;	
		if tipo_opcion = 'C' then
			fecha = current_date;
			hora = left(current_time::text, 8);
		end if;
		if tipo_opcion ='A' then
			fecha = '1800-01-01 00:00:00'::date;
			hora = '';
		end if;
	raise notice '%','tipo_operacion: ' ||tipo_operacion;	
		if tipo_operacion = 'TOTS' then
			update keplersc.kdpun set c23=tipo_opcion, c29=hora, c34=fecha
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
			
			update keplersc.kdtot set c14 = (select c6 from keplersc.kdmargen where c1=tipo_orden)
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
    	end if;
    	if  tipo_operacion = 'CARGOS' then	
    		update keplersc.kdpun set c24=tipo_opcion, c30=hora, c35=fecha
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
    			
    		update keplersc.kdcar set c9 = (select c7 from keplersc.kdmargen where c1=tipo_orden)
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		end if;
	
		if  tipo_operacion = 'REFS' then	
    		update keplersc.kdpun set c20=tipo_opcion, c26=hora, c31=fecha
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
    			
    		update keplersc.kdref set c17 = (select c5 from keplersc.kdmargen where c1=tipo_orden)
				where c1=sucursal_id and c2=tipo_orden and c3=num_orden;
		end if;
		resultado := 1;
		mensaje := '';
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	raise notice '%','resultado:'||resultado;
	raise notice '%','mensaje:'||mensaje;
--raise exception '%', 'interrupcion manual';
exception
	when others then
		resultado := 0;
		mensaje := 'ser_cierra_abre_ord_cargos_tots() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
		
	end;
$function$
