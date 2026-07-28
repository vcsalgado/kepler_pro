CREATE OR REPLACE FUNCTION keplersc.cat_crud_cuentas_unidades(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza crud del catalogo de Cuentas contables de unidades
--Autor: Gad Miranda
--Fecha: 15/06/2023
--Bitacora de cambios
declare
	--Variables de definicion de documento
	k_clave_crud text = '';
	k_anio_crud text = '';
	k_sucursal_crud text = '';
	k_notas_descuento_crud text = '';
	k_ventas_fni_crud text = '';
	k_costo_fni_crud text = '';
	k_ventas_contado_crud text = '';
	k_proveedores_crud text = '';
	k_inventario_crud text = '';
	k_costo_ventas_crud text = '';
	k_precio_venta_crud text = '';
	k_iva_venta_crud text = '';
	k_iva_compra_crud text = '';
	k_costo_vent_tras_crud text = '';
	k_precio_vent_tras_crud text = '';
	k_c4 text = '';
	k_c5 text = '';
	k_c6 text = '';
	k_c7 text = '';
	k_c8 text = '';
	k_c9 text = '';
	k_c10 text = '';
	k_c11 text = '';
	k_c12 text = '';
	k_c13 text = '';
	k_c14 text = '';

	crud text = '';
	totReg numeric(1);
	
   --Variables de retorno
	resultado text = '';
	mensaje text = '0';
    adicionales text = '';
	
begin 
	
	k_clave_crud := (xpath('//document/k_clave_crud/text()', dataxml))[1];
	k_anio_crud := (xpath('//document/k_anio_crud/text()', dataxml))[1];
	k_sucursal_crud := (xpath('//document/k_sucursal_crud/text()', dataxml))[1];
	k_notas_descuento_crud := coalesce((xpath('//document/k_notas_descuento_crud/text()', dataxml))[1], '');
	k_ventas_fni_crud := coalesce((xpath('//document/k_ventas_fni_crud/text()', dataxml))[1], '');
	k_costo_fni_crud := coalesce((xpath('//document/k_costo_fni_crud/text()', dataxml))[1],'');
	k_ventas_contado_crud := coalesce((xpath('//document/k_ventas_contado_crud/text()', dataxml))[1],'');
	k_proveedores_crud := coalesce((xpath('//document/k_proveedores_crud/text()', dataxml))[1],'');
	k_inventario_crud := coalesce((xpath('//document/k_inventario_crud/text()', dataxml))[1],'');
	k_costo_ventas_crud := coalesce((xpath('//document/k_costo_ventas_crud/text()', dataxml))[1],'');
	k_precio_venta_crud := coalesce((xpath('//document/k_precio_venta_crud/text()', dataxml))[1],'');
	k_iva_venta_crud := coalesce((xpath('//document/k_iva_venta_crud/text()', dataxml))[1],'');
	k_iva_compra_crud := coalesce((xpath('//document/k_iva_compra_crud/text()', dataxml))[1],'');
	k_costo_vent_tras_crud := coalesce((xpath('//document/k_costo_vent_tras_crud/text()', dataxml))[1],'');
	k_precio_vent_tras_crud := coalesce((xpath('//document/k_precio_vent_tras_crud/text()', dataxml))[1],'');

	crud := (xpath('//document/input_crud/text()', dataxml))[1];


	if crud = 'NUEVO' then
		select count(*) into totReg from keplersc.kdivcl where c1=k_clave_crud and c2=k_anio_crud and c3=k_sucursal_crud;
			if totReg > 0 then
   				raise exception 'Error, El registro ya existe';
			end if;

		insert into keplersc.kdivcl
			(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,c19,
				c20,c21,c22,c23,c24,c25,c26) 
		values(	k_clave_crud,k_anio_crud,k_sucursal_crud,k_c4,k_c5,k_c6,k_c7,k_c8,k_c9,k_c10,
				k_c11,k_c12,k_c13,k_c14,k_notas_descuento_crud,k_ventas_fni_crud,
				k_costo_fni_crud,k_ventas_contado_crud,k_proveedores_crud,k_inventario_crud,
				k_costo_ventas_crud,k_precio_venta_crud,k_iva_venta_crud,k_iva_compra_crud,
				k_costo_vent_tras_crud,k_precio_vent_tras_crud);
	end if;

	if crud = 'MODIFICAR' then
		update keplersc.kdivcl as n
			set  c15=k_notas_descuento_crud,c16=k_ventas_fni_crud,c17=k_costo_fni_crud
				,c18=k_ventas_contado_crud,c19=k_proveedores_crud,c20=k_inventario_crud
				,c21=k_costo_ventas_crud,c22=k_precio_venta_crud,c23=k_iva_venta_crud
				,c24=k_iva_compra_crud,c25=k_costo_vent_tras_crud,c26=k_precio_vent_tras_crud
			where c1=k_clave_crud and c2=k_anio_crud and c3=k_sucursal_crud;
	end if;

	if crud = 'ELIMINAR' then
		delete from keplersc.ini
			where  c1=k_clave_crud and c2=k_anio_crud and c3=k_sucursal_crud ;
	end if;

	resultado := 1;
	mensaje := 'Registro agregado:' || k_clave_crud || k_anio_crud || k_sucursal_crud;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cat_crud_partes() ' || '['|| sqlstate || '] ' || sqlerrm ;		
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
