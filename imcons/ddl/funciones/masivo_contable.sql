CREATE OR REPLACE FUNCTION keplersc.masivo_contable(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Edita Tabla KDIVCL
--Autor: Luis Leal
--Fecha: 30/05/2023
--Bitacora de cambios
declare
	sucursal_id text;
	anio text;
	
	clave_vehiculo text;
	n_descuento text; 
	ventas_fi text;
	costo_fi text;
	ventas_ctdo text;
	proveedores text;
	inventario text; 
	costo text;
	venta text;
	iva_venta text; 
	iva_compra text;
	traspaso_costo text;
	traspaso_venta text;

	no_partidas int = 0;
	strValor text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	
	sucursal_id:=coalesce((xpath('//document/k_sucN/r1/text()', dataxml))[1],'');
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1],'');
	anio := right(anio, 2);
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	for cont in 0..no_partidas loop
		
		clave_vehiculo := coalesce((xpath('//document/k_mov/r' ||cont||'/clave_vehiculo/text()',dataxml))[1],'');
		n_descuento := coalesce((xpath('//document/k_mov/r' ||cont||'/n_descuento/text()',dataxml))[1],'');
		ventas_fi := coalesce((xpath('//document/k_mov/r' ||cont||'/ventas_fi/text()',dataxml))[1],'');
		costo_fi := coalesce((xpath('//document/k_mov/r' ||cont||'/costo_fi/text()',dataxml))[1],'');
		ventas_ctdo := coalesce((xpath('//document/k_mov/r' ||cont||'/ventas_ctdo/text()',dataxml))[1],'');
		proveedores := coalesce((xpath('//document/k_mov/r' ||cont||'/proveedores/text()',dataxml))[1],'');
		inventario := coalesce((xpath('//document/k_mov/r' ||cont||'/inventario/text()',dataxml))[1],'');
		costo := coalesce((xpath('//document/k_mov/r' ||cont||'/costo/text()',dataxml))[1],'');
		venta := coalesce((xpath('//document/k_mov/r' ||cont||'/venta/text()',dataxml))[1],'');
		iva_venta := coalesce((xpath('//document/k_mov/r' ||cont||'/iva_venta/text()',dataxml))[1],'');
		iva_compra := coalesce((xpath('//document/k_mov/r' ||cont||'/iva_compra/text()',dataxml))[1],'');
		traspaso_costo := coalesce((xpath('//document/k_mov/r' ||cont||'/traspaso_costo/text()',dataxml))[1],'');
		traspaso_venta := coalesce((xpath('//document/k_mov/r' ||cont||'/traspaso_venta/text()',dataxml))[1],'');
	
		if clave_vehiculo = '' then
			if n_descuento = '' and ventas_fi = '' and costo_fi = '' and ventas_ctdo = ''
			and proveedores = '' and inventario = '' and costo = '' and venta = ''
			and iva_venta = '' and iva_compra = '' and  traspaso_costo = '' and traspaso_venta = '' then 
				continue;
			end if; 
			raise exception '%' ,'Error, no puede haber una Clave de Vehiculo vacia.'; 
		end if;
		
		update keplersc.kdivcl set c15=n_descuento, c16=ventas_fi, c17=costo_fi , c18=ventas_ctdo, c19=proveedores,
		c20=inventario, c21=costo, c22=venta, c23=iva_venta, c24= iva_compra, c25=traspaso_costo, c26= traspaso_venta
		where c1=clave_vehiculo and c2=anio and c3=sucursal_id ;
	
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'masivo_contable() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
