CREATE OR REPLACE FUNCTION keplersc.invr_rep_estxprod_sec_prod_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	producto text = '';
	anio text = '';
	usuario_movto text = '';

	--Variables de proceso
	transaccion_id text='';
	xmlResultados xml;
	error text = '';
	xmlRequest xml;
	strValor text = '';
	totRegistros int = 0;
	dateValor date;
	dateTmp date;

	--Variables de resultados de consultas
	resultado text  ='';
	mensaje text = '';
	adicionales text = '';		

	--Variables de retorno en xml, producto
	clave_original text = '';
	clave_actual text = '';
	cadena_reemplazo text = '';	
	loc_1 text = '';
	loc_2 text = '';
	loc_3 text = '';
	descripcion text = '';
	unidad text = '';
	clasificacion text  ='';
	linea text = '';
	backorder decimal = 0.00;
	phase text = '';
	mad decimal = 0.00;
	mip decimal = 0.00;
	mfd decimal = 0.00;

	cant_ent decimal = 0.00;
	cant_sal decimal = 0.00;
	monto_ent decimal = 0.00;
	monto_sal decimal = 0.00;
	ult_venta date;
	ult_compra date;
	ult_costo decimal = 0.00;
	pen_costo decimal = 0.00;
	pen_venta date;
	pen_compra date;
	min_reorden decimal = 0.00;

	existencias decimal = 0.00;
	valor decimal = 0.00;
	costo_promedio decimal = 0.00;
	costo_ultimo decimal = 0.00;


begin
	transaccion_id := keplersc.log_tran_id_gen();	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	producto := (xpath('//document/producto/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	usuario_movto := (xpath('//document/movimiento/usuario/text()', dataxml))[1];


	--Obtener clave original, actual y cadena de reemplazos
	select xmlforest(producto as clave_producto, anio as fecha, 'N' as criterio_fecha) :: text into strValor;

	select '<document>'||strValor||'</document>' into strValor;
	xmlRequest := strValor::xml;

	select * into clave_original, clave_actual, cadena_reemplazo from keplersc.prod_cadena_reemplazo(xmlRequest);
raise notice 'clave_original:% clave_actual:% cadena_reemplazo:%',clave_original, clave_actual, cadena_reemplazo;	
	--Obtener informacion del producto en tabla kdini
	select c2,c4,c5,c6,c19,c8,c9 into descripcion,loc_1,loc_2,loc_3,unidad,clasificacion,linea
		from keplersc.kdini where c1=clave_original;

	--Obtener informacion de backorder
	select c3-c4 into backorder from keplersc.kdbol where c1=sucursal_id and c2=clave_original;
	if not found then
	    backorder := 0.00;
	end if;	

	--Obtener info de pedido sugerido: phase, MID, MIP y Maxima Fluctuacion Demanda
	select c7 into dateValor from keplersc.kdpedidosugeridoconf where c1 = sucursal_id;
	if found then
		--Validar vigencia 
		select c3,c4,c5,c6 into phase, mad,mip,mfd 
			from keplersc.kdinp where c1=sucursal_id and c2=clave_original;
		if not found then 
			phase := '';
			mad := 0.00;
			mip := 0.00;
			mfd := 0.00;
		end if;
	    
	end if;		
	
	--Obtener informacion de entradas, salidas y promedios
	select c5,c6,c8,c9,c11,c12,c14,c15,c17,c18,c20 into 
		cant_ent,cant_sal,monto_ent,monto_sal,ult_venta,ult_compra,ult_costo,pen_costo,pen_venta,pen_compra,min_reorden
	from keplersc.kdinl where c1=sucursal_id and c2=clave_original;
	
	existencias := cant_ent - cant_sal;
	valor := monto_ent-monto_sal;
	if existencias > 0 then
		costo_promedio := valor/existencias;
	else
		costo_promedio := 0;
	end if;

	select xmlforest(clave_original as k_claveoriginal, clave_actual as k_claveactual,
		loc_1 as k_loc1, loc_2 as k_loc2, loc_3 as k_loc3, 
		descripcion as k_descproducto, unidad as k_unidad, clasificacion as k_clasificacion, linea as k_linea,
		backorder as k_backorder, phase as k_phase, mad as k_mad, mip as k_mip, mfd as k_mfd, 
		cant_ent as k_cant_ent,cant_sal as k_cant_sal,monto_ent as k_monto_ent,monto_sal as k_monto_sal,
		ult_venta as k_ult_venta,ult_compra as k_ult_compra,ult_costo as k_ult_costo,pen_costo as k_pen_costo,
		pen_venta as k_pen_venta,pen_compra as k_pen_compra,min_reorden as k_min_reorden, existencias as k_existencias,
		valor as k_valor, costo_promedio as k_costo_promedio) 
		into xmlResultados;
	return xmlResultados;
exception
	when sqlstate 'P0001' then --Raised error 
		raise exception '%', sqlerrm;
	when others then
		error := 'keplersc.invr_rep_estxprod_sec_prod_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, '0', 'keplersc.invr_rep_estxprod_sec_prod_sel', false, error, 'ERR', dataxml);
		raise exception '%', error;	
end;
$function$
