CREATE OR REPLACE FUNCTION keplersc.cat_confpolizasfacturas_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: CRUD de Configuracion de polizas
--Autor: Victor Salgado
--Fecha: 23/10/2025
--Bitacora de cambios

declare
	--Variables de definicion de documento
	k_id_tipo_factura text = '';
	k_descripcion_factura text = '';
	k_tipo_poliza text = '';
	k_descripcion_poliza text = '';
	k_referencia_poliza text = '';
	k_conceptos_origen text = '';

	k_tipo_asiento text = '';
	k_cuenta text = '';
	k_complemento_cuenta text = '';
	k_descripcion_partida text = '';
	k_tipo_movto text = '';
	k_id_concepto text = '';
	k_cuenta_grupo text = '';
	k_cuenta_divisible text = '';
	k_campo_cuenta_plantilla text ='';
	k_referencia_partida text = '';
	k_costo_inventario text = '';

	partidas_impuestos numeric = 0;
	partidas_provision numeric = 0;
	partidas_pagos numeric = 0;

	totReg numeric=0;
	cont numeric = 0;
	strValor text = '';
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin

	k_id_tipo_factura:=(xpath('//document/k_clave/text()', dataxml))[1]::text;
	k_descripcion_factura:=(xpath('//document/k_descripcion/text()', dataxml))[1]::text;
	strValor:=(xpath('//document/k_impuestos/no_partidas_impuesto/text()', dataxml))[1]::text;
	partidas_impuestos:=strValor::numeric;

	strValor:=(xpath('//document/k_provision/no_partidas_provision/text()', dataxml))[1]::text;
	partidas_provision :=strValor::numeric;

	strValor:=(xpath('//document/k_pago/no_partidas_pago/text()', dataxml))[1]::text;
	partidas_pagos:=strValor::numeric;

	for cont in 0..partidas_impuestos -1 loop
		strValor:=(xpath('//document/k_impuestos/r' || cont || '/id_concepto/text()', dataxml))[1]::text;

		k_conceptos_origen = concat(k_conceptos_origen, strValor);
		strValor:=(xpath('//document/k_impuestos/r' || cont || '/monto/text()', dataxml))[1]::text;
		k_conceptos_origen = concat(k_conceptos_origen, '=', strValor,'|');
	end loop;
	k_conceptos_origen:=substring(k_conceptos_origen,1,length(k_conceptos_origen)-1);
raise notice 'PASO 1 %',k_conceptos_origen;
	--Eliminar registros actuales del master y detalle
	delete from keplersc.conf_polizas_facturas_mst where id_tipo_factura=k_id_tipo_factura;
	delete from keplersc.conf_polizas_facturas_det where id_tipo_factura=k_id_tipo_factura;

	--Insertar en master
	insert into keplersc.conf_polizas_facturas_mst (id_tipo_factura,descripcion_factura,tipo_poliza,descripcion_poliza,referencia_poliza,conceptos_origen)
		values(k_id_tipo_factura,k_descripcion_factura,k_tipo_poliza,k_descripcion_poliza,k_referencia_poliza,k_conceptos_origen);

	--Insertar el detalle de provision
	for cont in 0..partidas_provision -1 loop
		k_tipo_asiento:=(xpath('//document/k_provision/r' || cont || '/tipo_asiento/text()', dataxml))[1]::text;
		k_cuenta:=(xpath('//document/k_provision/r' || cont || '/cve_cuenta/text()', dataxml))[1]::text;
		k_complemento_cuenta:=coalesce((xpath('//document/k_provision/r' || cont || '/complemento/text()', dataxml))[1]::text,'');
		k_tipo_movto:='PROV';
		k_id_concepto:=(xpath('//document/k_provision/r' || cont || '/id_concepto/text()', dataxml))[1]::text;
		k_cuenta_grupo:=(xpath('//document/k_provision/r' || cont || '/cuenta_gpo/text()', dataxml))[1]::text;
		k_cuenta_divisible:=coalesce((xpath('//document/k_provision/r' || cont || '/cuenta_divisible/text()', dataxml))[1]::text,'');		
		k_campo_cuenta_plantilla:=coalesce((xpath('//document/k_provision/r' || cont || '/campo_cuenta_plantilla/text()', dataxml))[1]::text,'');
		if k_campo_cuenta_plantilla <> '' then
			k_campo_cuenta_plantilla := split_part(k_campo_cuenta_plantilla,'-',1);
		end if;

		k_descripcion_partida:=coalesce((xpath('//document/k_provision/r' || cont || '/descripcion_partida/text()', dataxml))[1]::text,'');

		k_costo_inventario:=coalesce((xpath('//document/k_provision/r' || cont || '/costo_inventario/text()', dataxml))[1]::text,'N');
		insert into keplersc.conf_polizas_facturas_det(id_tipo_factura,tipo_asiento,cuenta,complemento_cuenta,descripcion_partida,referencia_partida,tipo_movto,id_concepto,cuenta_grupo,cuenta_divisible,campo_cuenta_plantilla,costo_inventario)
		values(k_id_tipo_factura,k_tipo_asiento,k_cuenta,k_complemento_cuenta,k_descripcion_partida,k_referencia_partida,k_tipo_movto,k_id_concepto,k_cuenta_grupo,k_cuenta_divisible,k_campo_cuenta_plantilla,k_costo_inventario);
	end loop;

	--Insertar el detalle de pago
	for cont in 0..partidas_pagos -1 loop
		k_tipo_asiento:=(xpath('//document/k_pago/r' || cont || '/tipo_asiento/text()', dataxml))[1]::text;
		k_cuenta:=(xpath('//document/k_pago/r' || cont || '/cve_cuenta/text()', dataxml))[1]::text;
		k_complemento_cuenta:=coalesce((xpath('//document/k_pago/r' || cont || '/complemento/text()', dataxml))[1]::text,'');
		k_tipo_movto:='PAGO';
		k_id_concepto:=(xpath('//document/k_pago/r' || cont || '/id_concepto/text()', dataxml))[1]::text;
		k_cuenta_grupo:=(xpath('//document/k_pago/r' || cont || '/cuenta_gpo/text()', dataxml))[1]::text;
		k_cuenta_divisible:=coalesce((xpath('//document/k_pago/r' || cont || '/cuenta_divisible/text()', dataxml))[1]::text,'');
		k_campo_cuenta_plantilla:=coalesce((xpath('//document/k_pago/r' || cont || '/campo_cuenta_plantilla/text()', dataxml))[1]::text,'');
		if k_campo_cuenta_plantilla <> '' then
			k_campo_cuenta_plantilla := split_part(k_campo_cuenta_plantilla,'-',1);
		end if;

		k_descripcion_partida:=coalesce((xpath('//document/k_pago/r' || cont || '/descripcion_partida/text()', dataxml))[1]::text,'');

		k_costo_inventario:=coalesce((xpath('//document/k_pago/r' || cont || '/costo_inventario/text()', dataxml))[1]::text,'N');

		insert into keplersc.conf_polizas_facturas_det(id_tipo_factura,tipo_asiento,cuenta,complemento_cuenta,descripcion_partida,referencia_partida,tipo_movto,id_concepto,cuenta_grupo,cuenta_divisible,campo_cuenta_plantilla,costo_inventario)
		values(k_id_tipo_factura,k_tipo_asiento,k_cuenta,k_complemento_cuenta,k_descripcion_partida,k_referencia_partida,k_tipo_movto,k_id_concepto,k_cuenta_grupo,k_cuenta_divisible,k_campo_cuenta_plantilla,k_costo_inventario);
	end loop;

	resultado := 1;
	mensaje := 'Registro agregado: ' || k_id_tipo_factura ;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_confpolzas_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
