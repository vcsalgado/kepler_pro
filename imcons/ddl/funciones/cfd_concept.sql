CREATE OR REPLACE FUNCTION keplersc.cfd_concept(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_cfdi text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Genera informacion para CFDI. Resuelve CFD_CONCEPT 
--Autor: Miriam Santana
--Fecha: 05/10/2022
--Bitacora de cambios
--12/08/2025 Miriam Santana: Enviar el desglose de los conceptos agrupados por paquete parametrizado

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	factura_paquete text = 'N';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	
begin
		--Transaccion
		sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
		genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
		naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
		grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
		tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	
	if genero = 'U' and (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
		
		if (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'G' then         
	         if (xpath('//row/c86/text()', xmlKDMM))[1]::text <> 'C' then 
	         	--CALL CFD_CONCEPT_ANTICIPO
	         	select * into resultado, mensaje, adicionales from keplersc.cfd_concept_anticipo(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
			    if resultado = '0' then
					raise exception '%',mensaje;
				end if; 
	         else 
	         	--CFD_CONCEPT_NOTA_CARGO
	            select * into resultado, mensaje, adicionales from keplersc.cfd_concept_nota_cargo(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
			    if resultado = '0' then
					raise exception '%',mensaje;
				end if; 
	         end if;
		end if; 
	    if (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'V' then             
	    	--CALL CFD_CONCEPT_VEHICULO
	    	select * into resultado, mensaje, adicionales from keplersc.cfd_concept_vehiculo(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if; 
	  	end if; 
	    if (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'S' then   
	    	--MSS 12082025 Enviar desglose por paquete cuando el parametro ='S'
	    	select coalesce(valor,'N') into factura_paquete from keplersc.param_oper where sucursal = sucursal_id and lower(parametro) = lower('MO negativa y concepto x paq CFDI');
	    	if factura_paquete = 'S' then
	    		--CALL CFD_CONCEPT_SERVICIO_XPAQUETE
		    	select * into resultado, mensaje, adicionales from keplersc.cfd_concept_servicio_xpaquete(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
	    	else		--MSS 12082025 Enviar el desglose de los conceptos de la forma original
		    	--CALL CFD_CONCEPT_SERVICIO
		    	select * into resultado, mensaje, adicionales from keplersc.cfd_concept_servicio(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;  
			end if;
		end if; 
	  	if (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'R' then       
	  		--CALL CFD_CONCEPT_PARTES
	  		select * into resultado, mensaje, adicionales from keplersc.cfd_concept_partes(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if; 

	    end if;
/*	  Se quita esta validación para que no realice ningún ajuste y no modifique la primer partida 
	    if (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'V' or (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'S' 
	    	or (xpath('//row/c88/text()', xmlKDMM))[1]::text = 'R' then     --si entra 
	        select * into resultado, mensaje, adicionales from keplersc.cfd_concept_valida_totales(dataxml,xmlkdm1, xmlkdmm,folio_cfdi); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if; 
	    end if; 
*/	    
		
		resultado := 1;
		mensaje := '';
		adicionales := '';
		return query select resultado, mensaje, adicionales;
		
	end if;
exception
	when others then
		resultado := 0;
		mensaje := 'cfd_concept() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
