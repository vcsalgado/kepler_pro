CREATE OR REPLACE FUNCTION keplersc.ser_componentes_mantto(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Grabar los componentes de mantenimiento completo, medio o basico 
--Autor: Miriam Santana
--Fecha: 28/05/2024
--Bitacora de cambios

declare
		sucursal_id text ='';
		tipo_orden text ='';
		folio_orden text ='';
		cve_comp text ='';
		desc_comp text ='';
		estatus text ='';
		observaciones text ='';
		tabla text ='';
		tipo_mantto text ='';
		strPartidas text ='';
		
		no_partidas int;
		totReg int;	
		strValor text;
		resultado text = '';
		mensaje text = '';
	    adicionales text = '';
   
begin 
	
		sucursal_id := (xpath('//document/k_sucursal/text()', dataxml))[1]; 
	 	tipo_orden := coalesce((xpath('//document/k_tipo/text()', dataxml))[1]::text,'')::text; 
	 	folio_orden := coalesce((xpath('//document/k_folio/text()', dataxml))[1]::text,'')::text; 
	 	tabla := coalesce((xpath('//document/tabla/text()', dataxml))[1]::text,'')::text; 
	 	tipo_mantto := coalesce((xpath('//document/tipo_mantto/text()', dataxml))[1]::text,'')::text; 
	 	
		strPartidas := (xpath('//document/tbl_componentes/no_partidas/text()',dataxml))[1];
		no_partidas := strPartidas::integer;
		--Eliminar componentes
		select count(*) into totReg from keplersc.kdcompord 
			where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		if totReg>0 then
			delete from keplersc.kdcompord
				where c1=sucursal_id and c2=tipo_orden and c3=folio_orden;
		end if;
		--Procesar detalle de componentes
		for cont in 0..no_partidas - 1 loop
			cve_comp := coalesce((xpath('//document/tbl_componentes/r'||cont||'/cve_comp/text()', dataxml))[1]::text,'')::text;
			desc_comp := coalesce((xpath('//document/tbl_componentes/r'||cont||'/desc_comp/text()', dataxml))[1]::text,'')::text;
			estatus := coalesce((xpath('//document/tbl_componentes/r'||cont||'/estatus/text()', dataxml))[1]::text,'')::text;
			observaciones := coalesce((xpath('//document/tbl_componentes/r'||cont||'/observaciones/text()', dataxml))[1]::text,'')::text;
		--	raise exception 'cve:% desc:% estatus:% observaciones:%',cve_comp,desc_comp,estatus,observaciones; 
			if estatus <> '' or observaciones <> '' then
				if estatus <> 'BUENO' and estatus <> 'REGULAR' and estatus <> 'MALO' and estatus <> 'SE REALIZO' and estatus <> 'NO APLICA' then 
					raise exception 'Verifique %-%. El estatus solo puede ser SE REALIZO, BUENO, REGULAR, MALO o NO APLICA',cve_comp,desc_comp;				
				end if;
	 			
				insert into keplersc.kdcompord
					(c1,c2,c3,c4,c5,
					c6,c7,c8)
				values(
					sucursal_id,tipo_orden,folio_orden,cve_comp,desc_comp,
					estatus,observaciones,tipo_mantto);
	 	 
	 		end if;
	 
	 	end loop;
	 
		resultado := 1;
		mensaje := 'Componente Registrado';
		adicionales := folio_orden ;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'ser_componentes_mantto() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
