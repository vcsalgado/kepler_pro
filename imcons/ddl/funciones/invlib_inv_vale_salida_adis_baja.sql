CREATE OR REPLACE FUNCTION keplersc.invlib_inv_vale_salida_adis_baja(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Saltiel CRUZ. 13/ENE/2022
	
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
	v_Cargos_de_Bonificaciones numeric = 0;
	v_Abonos_de_Bonificaciones numeric = 0;
	v_naturaleza_KDBONIF text = '';
	v_monto_KDBONIF numeric =0;
	v_genero_KDSUNICOSTO text = '';
	v_naturaleza_KDSUNICOSTO text = '';
	v_tipo_costo_KDSUNICOSTO text = '';
	v_costo_KDSUNICOSTO numeric =0;
	v_Cargo_al_Costo_de_Accesorios numeric = 0;
	v_Cargo_al_costo_de_Unidades numeric = 0;
	v_Abono_al_Costo_de_Accesorios numeric = 0;
	v_Abono_al_Costo_de_Unidades numeric = 0;
	v_subsidio numeric = 0 ;
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
	
	if (select count(*) from keplersc.kdpedido where c1 = sucursal_id and c2 = v_inventario) > 0 then 
		select c15 into v_subsidio from keplersc.kdpedido WHERE c1 = sucursal_id and C2 = v_inventario;
		for v_naturaleza_KDBONIF,v_monto_KDBONIF in select c3,c10 from keplersc.KDBONIF where c1 = sucursal_id and c8 = v_inventario
		loop
				if v_naturaleza_KDBONIF = 'D' then 
					v_Cargos_de_Bonificaciones = v_Cargos_de_Bonificaciones + v_monto_KDBONIF;--B7010
				else
					v_Abonos_de_Bonificaciones= v_Abonos_de_Bonificaciones + v_monto_KDBONIF; --B7011
				end if;
		end loop;
		for v_genero_KDSUNICOSTO,v_naturaleza_KDSUNICOSTO, v_tipo_costo_KDSUNICOSTO, v_costo_KDSUNICOSTO in 
		select c2,c3,c9,c10  from keplersc.KDSUNICOSTO where c7 = sucursal_id and c8 = v_inventario
		loop
				if (v_genero_KDSUNICOSTO = 'U' and v_naturaleza_KDSUNICOSTO = 'D') or (v_genero_KDSUNICOSTO = 'X' and v_naturaleza_KDSUNICOSTO = 'A') then --CARGO AL COSTO
					if v_tipo_costo_KDSUNICOSTO = 'A' then 
					v_Cargo_al_Costo_de_Accesorios = v_Cargo_al_Costo_de_Accesorios + v_costo_KDSUNICOSTO;
					end if;
					if v_tipo_costo_KDSUNICOSTO = 'U' then 
					v_Cargo_al_costo_de_Unidades = v_Cargo_al_costo_de_Unidades + v_costo_KDSUNICOSTO;
					end if;
				end if;
				if (v_genero_KDSUNICOSTO = 'U' and v_naturaleza_KDSUNICOSTO = 'A') or (v_genero_KDSUNICOSTO = 'X' and v_naturaleza_KDSUNICOSTO = 'D') then --CARGO AL COSTO
					if v_tipo_costo_KDSUNICOSTO = 'A' then 
					v_Abono_al_Costo_de_Accesorios = v_Abono_al_Costo_de_Accesorios + v_costo_KDSUNICOSTO;
					end if;
					if v_tipo_costo_KDSUNICOSTO = 'U' then 
					v_Abono_al_Costo_de_Unidades = v_Abono_al_Costo_de_Unidades + v_costo_KDSUNICOSTO;
					end if;
				end if;
		end loop;
		
		--raise notice 'baja_vale_%,%,%,%,%,%',sucursal_id,genero,naturaleza,grupo::numeric,tipo_clave::numeric,folio_operacion;
		insert into keplersc.KDCOMISADIS (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14) 
		values (sucursal_id,genero,naturaleza,grupo::numeric,tipo_clave::numeric,
				folio_operacion,1,v_subsidio,v_Cargos_de_Bonificaciones,
				v_Abonos_de_Bonificaciones,v_Cargo_al_Costo_de_Accesorios,v_Abono_al_Costo_de_Accesorios,v_Cargo_al_costo_de_Unidades,v_Abono_al_Costo_de_Unidades);
		
	end if;
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_vale_salida_adis_alta() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
