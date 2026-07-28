CREATE OR REPLACE FUNCTION keplersc.invlib_inv_factura(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Saltiel RC. 12/10/2022
	--actualizado:07/Dic/2022
	--Variables de definicion de documento	
	---'FACTURA DEL AUTOMOVIL 
	--Bitacora de cambios
	--05/03/2025 Miriam Santana: Alta/Baja de anticipos de una factura para relacionarlos en el CFDI

	v_sucursal_id text = '';
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
	v_n_partida numeric = 1;
	v_partida numeric = 0;--J KDVENTAS
 	v_estatus_alta_baja numeric = 0;
 	v_clave_cliente_proveedor text = '';
 	v_monto_iva text = '';
	v_monto_ieps_retencion text = '';
	v_importe text = '';
	v_folio text = '';

 	v_clave_del_vehiculo text = '';	
    v_marca text = '';
 	v_anio_modelo text = '';
 	v_nuevo_o_usado text = '';
 	v_color_exterior text = '';
 	v_vestiduras text = '';
 
   	v_coach text = '';
    v_clave_vendedor text = '';
    v_clave_operador text = '';
    v_es_flotilla text = '';
    v_descuento text = '';
    v_gastos_administrativos text = '';
    v_subsidio text = '';
    v_seguro_automovil text = '';
    v_garantia_extendida text = '';
    v_accesorios text = '';

	v_entradas_unidades numeric=0;---KDLINV
	v_salidad_unidades numeric=0;
	v_entradas_en_monto numeric=0;
	v_salidas_en_monto numeric=0;
	v_primera_fecha text = '';
	v_ultimo_costo text = '';
	v_costo numeric=0;	
	
	fecha_ref text;	
	gmac_ally text = '';
	codigo_cancel text = '';

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INVRLIB.INV_FACTURA M65=30 THEN 'FACTURA DEL AUTOMOVIL
	
	v_sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
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
	fecha_ref := coalesce((xpath('//document/k_fecref/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	--41
	gmac_ally:= coalesce((xpath('//document/k_gmac_ally/text()', dataxml))[1]::text,'')::text;
	codigo_cancel:= coalesce((xpath('//document/k_motivo_cancel/r1/text()', dataxml))[1]::text,'')::text;

	if genero = 'U' then
		
			select count(*) into v_partida from keplersc.KDVENTAS where c1 = v_sucursal_id  and c2 = v_inventario;
			v_n_partida = 1;
			if v_partida > 0 then			
				v_n_partida := v_partida + 1;		
			end if;
		
		if naturaleza = 'D' then --FACTURA
			v_estatus_alta_baja = 0;
		else --NOTA DE CREDITO
			v_estatus_alta_baja = 10;
		end if;
		
		if (select count(*) from keplersc.KDINF WHERE c1 = v_sucursal_id and C2 = v_inventario) > 0 and
			(select count(*) from keplersc.kdpedido WHERE c1 = v_sucursal_id and C2 = v_inventario) > 0 and
			(select count(*) from keplersc.KDLINV where c1 = v_sucursal_id and c2 = v_inventario) > 0 
			then			
				select c42,c10,c11,c29,c30,c17,c18,c19,c20,c15 into v_coach,v_clave_vendedor,v_clave_operador,v_es_flotilla,v_descuento,v_gastos_administrativos,
						v_accesorios,v_garantia_extendida,v_seguro_automovil,v_subsidio from keplersc.kdpedido WHERE c1 = v_sucursal_id and C2 = v_inventario;
				select c3,c4,c5,c6,c7,c8 into v_entradas_unidades,v_salidad_unidades,v_entradas_en_monto,v_salidas_en_monto,v_primera_fecha,v_ultimo_costo  from keplersc.KDLINV WHERE c1 = v_sucursal_id and C2 = v_inventario; 
				select c3,c10,c11,c15,c17,c21 into v_clave_del_vehiculo,v_color_exterior,v_vestiduras,v_anio_modelo,v_marca,v_nuevo_o_usado from keplersc.KDINF WHERE c1 = v_sucursal_id and C2 = v_inventario;
				select c10,c15,c14,c16,c6 into v_clave_cliente_proveedor,v_monto_ieps_retencion,v_monto_iva,v_importe,v_folio from keplersc.kdm1 where c2 = genero and c3 = naturaleza 
				and c4= grupo::numeric and c5 = tipo_clave::numeric and c6=folio_operacion and c100 = v_inventario;
			
				--no debe haber validaciones entre cero...			
				if (v_entradas_unidades - v_salidad_unidades) = 0 then --SI+363.00 EL COSTO PROMEDIO DA 0 TOMA EL ULTIMO COSTO 
					v_costo = v_ultimo_costo;
				else
					v_costo= ((v_entradas_en_monto - v_salidas_en_monto) / (v_entradas_unidades - v_salidad_unidades));
				end if; 
				
				insert into keplersc.KDVENTAS (c1,c2,c3,c4,c5,
					c6,c7,c8,c9,c10,
					c11,c12,c13,c14,c15,
					c16,c17,c18,c19,c20,
					c21,c22,c23,
					c24,c25,c26,
					c27,c28,c29,c30,
					c31,c32,c33,c34,c35,c36,
					contrato_gmac_ally,codigo_cancelacion) 
				values(v_sucursal_id, v_inventario, v_n_partida, genero, naturaleza,
						grupo::numeric, tipo_clave::numeric, folio_operacion,(select NOW()), v_estatus_alta_baja, 
						v_clave_cliente_proveedor,'', v_coach, v_clave_del_vehiculo, '', 
						v_clave_vendedor, v_clave_operador, v_marca, v_nuevo_o_usado, v_anio_modelo,
						'',v_color_exterior,v_vestiduras, 
						v_monto_ieps_retencion::numeric, v_monto_iva::numeric, v_importe::numeric,'',
						v_es_flotilla,v_costo::numeric,v_primera_fecha::timestamp,v_descuento::numeric,
						v_gastos_administrativos::numeric,v_accesorios::numeric,v_garantia_extendida::numeric,v_seguro_automovil::numeric,v_subsidio::numeric,
						gmac_ally,codigo_cancel);
				
				--ACTUALIZANDO EL DATO DE LA EMPRESA Y LA LINEA
				if (select count(*) from keplersc.kdventas WHERE c1 = v_sucursal_id and C4 = genero and c5=naturaleza and c6 = grupo::numeric and c7= tipo_clave::numeric and c8 =v_folio) > 0 and 
					(select count(*) from keplersc.KDUV WHERE c1 = v_sucursal_id and c2 = v_clave_vendedor) > 0 and
					(select count(*) from keplersc.KDIV where c1 = v_clave_del_vehiculo) > 0
				then 
					update keplersc.kdventas 
					set c15 = (select c4 from keplersc.KDUV WHERE c1 = v_sucursal_id and c2 = v_clave_vendedor),
						c21 = (select c7 from keplersc.KDIV where c1 = v_clave_del_vehiculo)
					WHERE c1 = v_sucursal_id and C4 = genero and c5=naturaleza and c6 = grupo::numeric and c7= tipo_clave::numeric and c8 =v_folio;
				end if;
				--call invlib_inv_status(:dataxml, :xmlkdmm) 			
				select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlKDMM);
				--CALL invlib_inv_alta 
				select * into resultado, mensaje, adicionales from keplersc.invlib_inv_alta(dataxml,xmlKDMM,folio_operacion); --dentro de la libreria se encuentra inv_alta_k				
				
				---------------------------------------------------------------
				--Alta/Baja de seleccion de anticipos de una factura para relacionarlos en el CFDI.		--MSS 05032025 seleccion de anticipos
				---------------------------------------------------------------
				select * into resultado, mensaje, adicionales from keplersc.cfd_alta_seleccion_anticipos(dataxml,folio_operacion);
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
				
		end if; --
	end if;--U

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_factura() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
