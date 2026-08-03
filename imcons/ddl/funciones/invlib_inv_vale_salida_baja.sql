CREATE OR REPLACE FUNCTION keplersc.invlib_inv_vale_salida_baja(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	
	--Autor: Saltiel Cruz
	--Fecha: 13 ENE 2022	
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	v_inventario text ='';	
	v_fecha_movto text='';
	v_folio text = '';
	totReg int = 0;

	--xml Movimiento
	xmlKDM1 xml;
	xmlKDM1_c3 text = '';	
	
	v_status numeric = 0;
	v_accesorios numeric =0;
	v_garantia_extendida numeric =0;	
	
	aux_sucursal text = '';
	aux_genero text = '';
	aux_naturaleza text = '';
	aux_grupo numeric = 0;
	aux_tipo numeric = 0;
	aux_folio text= '';
	aux_fecha timestamp;
	aux_inventario text= '';
	aux_vendedor text= '';
	aux_tipo_AB text= '';
	aux_tipo_operacion text= '';
	aux_modelo text= '';	
	aux_fecha_factura timestamp;
	aux_tipo_auto text= '';
	aux_descuento numeric = 0;
	aux_gastos_administrativos numeric = 0;
	aux_seguro numeric = 0;
	aux_accesorios numeric = 0;
	aux_garantia_extendida numeric = 0;
	aux_isan numeric = 0;
	aux_iva numeric = 0;
	aux_importe numeric = 0;
	aux_costo numeric = 0;	
	aux_fecha_segunda timestamp;
	aux_anio_modelo text = '';
	aux_coach text = '';

	aux_asesor_telemarketing text = ''; 	
	aux_asesor_toma_seminuevo text = ''; 	
	aux_valuador text = '';
	aux_fecha_pago_comision timestamp;
	aux_asesor_venta text = ''; 
	aux_comision_pagada text = '';
	aux_valor_baja text = '1';
--Variables de uso general	
	mensajeError text;		
	--folio_operacion text;
	xmlResultado xml;
			
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin
	-- Inicializacion de variables
	--folio_operacion := 0;
	get_resultado := '';
	get_adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	v_inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);
   	v_fecha_movto:= upper((xpath('//document/k_fecha/text()', dataxml))[1]::text);
	v_folio:=(xpath('//document/k_folio/text()', dataxml))[1]::text;

raise notice 'sucursal_id %',sucursal_id;
raise notice 'v_inventario %',v_inventario;
	
	--Validar que el inventario este en pedido
	select count(*) into totReg from keplersc.kdpedido where c1 = sucursal_id and c2 = v_inventario;
	if totReg=0 then
		raise exception 'El inventario no está registrado como pedido.';
	end if;

	--Validar que el vale de salida exista
	select count(*) into totReg from keplersc.kdcomismov 
		where c1 = sucursal_id and c8 = v_inventario and c6=v_folio and c10 = '0';
	if totReg=0 then
		raise exception 'El vale de salida % del inventario % no existe.',v_folio, v_inventario;
	end if;	

	--Validar que el vale de salida no este cancelado
--raise exception 'Suc:%; inv:%, folio:%',sucursal_id,v_inventario,v_folio;
	select count(*) into totReg from keplersc.kdcomismov 
		where c1 = sucursal_id and c8 = v_inventario and c6=v_folio and c10 = '1';
	if totReg>0 then
		raise exception 'El vale de salida % del inventario % ya está cancelado.',v_folio, v_inventario;
	end if;	
	
	--Insertar en kdcomismov 
		
	select c1,c2,c3,c4,c5,c6,c7,
	c8,c9,c10,c11,c12,c13,c14,
	c15,c16,c17,c18,c19,c20,c21,
	c22,c23,c24,c25,c26 into
	aux_sucursal,aux_genero,aux_naturaleza,	aux_grupo,aux_tipo,aux_folio,aux_fecha,
	aux_inventario,aux_vendedor,aux_tipo_AB,aux_tipo_operacion,aux_modelo,aux_fecha_factura,aux_tipo_auto,	
	aux_descuento,aux_gastos_administrativos,aux_seguro,aux_accesorios,	aux_garantia_extendida,	aux_isan,aux_iva,	
	aux_importe,aux_costo,aux_fecha_segunda,aux_anio_modelo,aux_coach
	from keplersc.kdcomismov where c1 = sucursal_id and c8 = v_inventario and c6=v_folio and c10 = '0' order by c7 desc limit 1;
		
--raise notice '%, %, %,	 %,	 %,	 %, %, %',aux_sucursal,aux_genero,aux_naturaleza,	aux_grupo,	aux_tipo,	aux_folio,aux_valor_baja,(select now()::timestamp);
	insert into keplersc.kdcomismov (c1,c2,c3,c4,c5,c6,c7,
		c8,c9,c10,c11,c12,c13,c14,
		c15,c16,c17,c18,c19,c20,c21,
		c22,c23,c24,c25,c26)
	values (aux_sucursal,aux_genero,aux_naturaleza,	aux_grupo,aux_tipo,aux_folio,v_fecha_movto::timestamp,	
		aux_inventario,aux_vendedor,aux_valor_baja,aux_tipo_operacion,aux_modelo,aux_fecha_factura,aux_tipo_auto,
		aux_descuento,aux_gastos_administrativos,aux_seguro,aux_accesorios,aux_garantia_extendida,aux_isan,	aux_iva,
		aux_importe,aux_costo,aux_fecha_segunda,aux_anio_modelo,aux_coach);

	select c1,c2,c3,c4,c5,c6,c7,c8,
		c9,c10,c11,c12,c13,
		c14,c15,c16 into 
	aux_sucursal,aux_genero,aux_naturaleza,aux_grupo,aux_tipo,aux_folio,aux_fecha, aux_inventario,	
	aux_asesor_telemarketing, aux_tipo_AB, aux_tipo_operacion,aux_asesor_toma_seminuevo, aux_valuador,	
	aux_fecha_pago_comision,aux_asesor_venta,aux_comision_pagada
	from keplersc.kdcomismov2 where c1 = sucursal_id and c8 = v_inventario and c6=v_folio and c10 = '0' order by c7 desc limit 1;

	insert into keplersc.kdcomismov2 (c1,c2,c3,c4,c5,c6,c7,
		c8,c9,c10,c11,c12,
		c13,c14,c15,c16 ) 
	values (aux_sucursal,aux_genero,aux_naturaleza,aux_grupo,aux_tipo,aux_folio,v_fecha_movto::timestamp,
		aux_inventario,aux_asesor_telemarketing,aux_valor_baja,aux_tipo_operacion,aux_asesor_toma_seminuevo, 
		aux_valuador,aux_fecha_pago_comision,aux_asesor_venta,aux_comision_pagada);
		
	
	--paso:= 'docdis.invlib_INV_VALE_SALIDA_ADIS_BAJA';
	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_vale_salida_adis_baja(dataxml,xmlkdmm,folio_operacion);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	
  	raise notice 'fin en invlib_inv_vale_salida_adis_baja';

	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;	
	raise notice 'fin en invlib_inv_status';
	get_resultado:=1;
	get_mensaje:=folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_inv_vale_salida_baja() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		raise notice 'err sqlState %',mensaje ;
		return query select resultado, mensaje, adicionales;	
end;
$function$
