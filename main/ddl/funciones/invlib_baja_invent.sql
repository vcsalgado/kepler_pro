CREATE OR REPLACE FUNCTION keplersc.invlib_baja_invent(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Saltiel RC. 13/ENE/2023
	--
	--
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	v_inventario text ='';
	v_pedimento  text ='';
	clave_cteprov text ='';
	clave_vendedor text = '';
	tipo_operacion text = '';
	tipo_movto text = '';
	v_fecha_referencia text = '';
	v_saldo_documento text = '';
	v_paridad text = '';
	v_dias_retraso text = '';
	v_iva_desglosado text = '';
	v_tasa_interes_moratorio text = '';
	v_clave_cliente_provedor_secundario text = '';	
	v_isan text = '';
	v_iva text = '';
	v_importe text = '';
	fecha_ref text;
	iva_desglosado text ='';
	tipo_auto text = '';

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INVRLIB.ALTA_INVENT	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	tipo_movto := (xpath('//document/tipo_movto/text()', dataxml))[1];
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	clave_cteprov := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;
	clave_vendedor := coalesce((xpath('//document/k_vendedor/text()', dataxml))[1]::text,'')::text;
	tipo_operacion := coalesce((xpath('//document/operacion/text()', dataxml))[1]::text,'')::text;--c97
	v_pedimento := upper((xpath('//document/k_pedimento/text()', dataxml))[1]::text);
	v_isan := coalesce((xpath('//document/subt/text()',dataxml))[1]::text,'0')::text;
	v_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	v_importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	fecha_ref := coalesce((xpath('//document/k_fecref/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	--41
	iva_desglosado := coalesce((xpath('//document/k_ivadesglosado/text()',dataxml))[1]::text,'')::text;
	tipo_auto := coalesce((xpath('//document/k_tipoauto/text()',dataxml))[1]::text,'')::text;
		
	if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' then
				------------- VALE DE SALIDA 
				--------------------------------------------------------------
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '20' then 
				end if;
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '50' then 
				end if;
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '70' then 
				--paso:= 'docdis.invlib_INV_VALE_SALIDA_BAJA';			
					select * into resultado, mensaje, adicionales from keplersc.invlib_inv_vale_salida_baja(dataxml,xmlkdmm,folio_operacion);			
					if resultado = '0' then					
						raise exception '%',mensaje;
					end if;	
				end if;
				--------------------------------------------------------------
				------------- END VALE DE SALIDA 
				--------------------------------------------------------------
			raise notice 'END VALE DE SALIDA';		 
			
	end if;
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_alta_invent() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
