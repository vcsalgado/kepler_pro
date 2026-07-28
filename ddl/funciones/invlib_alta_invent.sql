CREATE OR REPLACE FUNCTION keplersc.invlib_alta_invent(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Saltiel RC. 12/10/2022
	--Variables de definicion de documento	
	
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
	v_isan := coalesce((xpath('//document/subt/text()',dataxml))[1]::text,'0')::text;
	v_iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	v_importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	fecha_ref := coalesce((xpath('//document/k_fecref/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;	--41
	iva_desglosado := coalesce((xpath('//document/k_ivadesglosado/text()',dataxml))[1]::text,'')::text;
	tipo_auto := coalesce((xpath('//document/k_tipoauto/text()',dataxml))[1]::text,'')::text;
	
	--------------------------------------------------------------
	------------- INV_PEDIDO_ALTA 
	--------------------------------------------------------------
	if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '20' then 
		
		if (select count(*) from keplersc.kdpedido where c1 = v_sucursal_id and c2 = v_inventario) = 0 
			then
			insert into keplersc.kdpedido (c1,c2,c3,c4,c5,c6,c7) 
			values (v_sucursal_id , v_inventario,genero, naturaleza,grupo::numeric,tipo_clave::numeric,folio_operacion);
		end if;
		
		update keplersc.kdpedido 
		set c8 = to_date(fecha_operacion,'YYYY-MM-DD'),
			c9 = clave_cteprov,
			c10 = clave_vendedor,
			c11 = tipo_operacion,
			c42 = v_pedimento,
			c12 = v_isan::numeric,
			c13 = v_iva::numeric,
			c14 = v_importe::numeric,
			c15 = 0,
			c16 = 0,
			c17 = 0,
			c18 = 0,
			c19 = 0,
			c20 = 0,
			c21 = fecha_ref::timestamp ,
			c22 = 0,
			c23 = 0,
			c24 = 0,
			c25 = 0,
			c26 = iva_desglosado::text,
			c27 = 0,
			c28 = 0,
			c29 = tipo_auto,
			c30 = 0,
			c31 = 0,
			c32 = 0,
			c33 = 0,
			c34 = 0,
			c35 = 0,
			c36 = 0,
			c37 = 0,
			c38 = 'S',
			c39 = 'S',
			c40 = 'S',
			c41 = 'S'
		where 
				c1 = v_sucursal_id and 
				c2 = v_inventario and 
				c3 = genero and 
				c4 = naturaleza and
				c5 = grupo::numeric and 
				c6 = tipo_clave::numeric and 
				c7 = folio_operacion;
	
			--INSERTANDO DATOS DE DOCUMENTOS EN KDINF
		select c41,c42,c40,c86,c98,c87,c46 into v_fecha_referencia,	v_saldo_documento,v_paridad,v_dias_retraso,v_iva_desglosado,v_tasa_interes_moratorio,v_clave_cliente_provedor_secundario from keplersc.KDM1 where c1 = v_sucursal_id and 
				c100 = v_inventario and c2 = genero and c3 = naturaleza and	c4 = grupo::numeric and c5 = tipo_clave::numeric and c6 = folio_operacion;
		
		 update keplersc.kdinf 
		 set c72 =v_fecha_referencia::timestamp, 
		 	 c73 = v_saldo_documento::numeric ,
		 	 c74 = v_paridad::numeric ,
		 	 c75 = v_dias_retraso::numeric ,
		 	 c76 = v_iva_desglosado,
		 	 c77 = v_tasa_interes_moratorio::numeric ,
		 	 c78 = 'N',
		 	 c32 = 10 -- PEDIDO REGISTRADO
		 where  c1 = v_sucursal_id and c31 = 20 and c2 = v_inventario;
		-- raise notice ' Paso 2b';
		if v_iva_desglosado='S' then
		   --FOR N1=1 TO NMOV
	    	-- insert into keplersc.KDPEDDOCS (c1,c2,c3,c4,c5) values INS(J,W1,W100,N1,DMOV(N1,1),DMOV(N1,3))
		   --NEXT
		 end if;
		--if (select (*) from keplersc.KDPERFIL where c1 = > 0 )BUS(K,1,0,W46,W47)>0 then	
		--end if;		
	end if;
	
		--------------------------------------------------------------
		------------- END INV_PEDIDO_ALTA
		--------------------------------------------------------------
	--------------------------------------------------------------
	------------- FACTURA DEL AUTOMOVIL
	--------------------------------------------------------------
	
	if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '30' then 
			--paso:= 'docdis.invlib_inv_factura';
			select * into resultado, mensaje, adicionales from keplersc.invlib_inv_factura(dataxml,xmlkdmm,folio_operacion);			
			if resultado = '0' then					
				raise exception '%',mensaje;
			end if;	
	end if;
		--------------------------------------------------------------
		------------- END FACTURA DEL AUTOMOVIL
		--------------------------------------------------------------
	--------------------------------------------------------------
	------------- VALE DE SALIDA 
	--------------------------------------------------------------
	if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '70' then 
			--paso:= 'docdis.invlib_INV_VALE_SALIDA_ALTA';			
			select * into resultado, mensaje, adicionales from keplersc.invlib_inv_vale_salida_alta(dataxml,xmlkdmm,folio_operacion);			
			if resultado = '0' then					
				raise exception '%',mensaje;
			end if;	
	end if;
	--------------------------------------------------------------
	------------- END VALE DE SALIDA 
	--------------------------------------------------------------
	raise notice 'END VALE DE SALIDA';
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
