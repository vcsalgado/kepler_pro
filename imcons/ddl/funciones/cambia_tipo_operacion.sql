CREATE OR REPLACE FUNCTION keplersc.cambia_tipo_operacion(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: cambia tipo operacion
--Autor: Luis Leal
--Fecha: 26/05/2023
--Bitacora de cambios
declare
		sucursal_id text;
		inventario text;
		tipo_operacion text;
		unidad_traslado text;
		asesor text;
		coach text;
		modelo text;
		asesor_comprador text;
		coach_comprador text;
		valuador_comprador text;
		fecha_factura date;
		fecha_vale_salida date;
		fecha_compra date;
		linea_vehiculo text;

		--loop
		partida int;
		fecha_fact date;
	
		
		begin 
	
		sucursal_id := (xpath('//document/k_sucN/r1/text()', dataxml))[1]; 
	 	inventario := coalesce((xpath('//document/inventario/text()', dataxml))[1]::text,'')::text; 
	 	tipo_operacion := coalesce((xpath('//document/tipo_operacion/text()', dataxml))[1]::text,'')::text; 
	 	unidad_traslado := coalesce((xpath('//document/unidad_traslado/text()', dataxml))[1]::text,'N')::text; 
	 	asesor := coalesce((xpath('//document/asesor/text()', dataxml))[1]::text,'')::text; 
	 	coach := coalesce((xpath('//document/coach/text()', dataxml))[1]::text,'')::text; 
	 	modelo := coalesce((xpath('//document/modelo/text()', dataxml))[1]::text,'')::text; 
	 	asesor_comprador := coalesce((xpath('//document/asesor_comprador/text()', dataxml))[1]::text,'')::text; 
	 	coach_comprador := coalesce((xpath('//document/coach_comprador/text()', dataxml))[1]::text,'')::text; 
	 	valuador_comprador := coalesce((xpath('//document/valuador_comprador/text()', dataxml))[1]::text,'')::text; 
	 	fecha_factura := (xpath('//document/fecha_factura/text()', dataxml))[1]; 
	 	fecha_vale_salida := (xpath('//document/fecha_vale_salida/text()', dataxml))[1]; 
	 	fecha_compra := (xpath('//document/fecha_compra/text()', dataxml))[1]; 
	 	 
	 
	 	select c7 into linea_vehiculo from keplersc.kdiv where c1 = modelo;
	 
	 
		update keplersc.kdventas set c17=tipo_operacion, c13=coach, 
		c16=asesor, c14= modelo, c21= linea_vehiculo, c30=fecha_compra
		where c1=sucursal_id and c2=inventario ;
	
		update keplersc.kdventas set c9=fecha_factura 
		where c9 > fecha_factura and c1=sucursal_id and c2=inventario ;
	
	
		update keplersc.kdcomismov set c11=tipo_operacion,
		c26=coach, c9=asesor, c12=modelo, c24=fecha_compra
		where c1=sucursal_id and c8=inventario ;
	
		update keplersc.kdcomismov set c7=fecha_vale_salida 
		where c7 > fecha_vale_salida and c1=sucursal_id and c8=inventario;
	
	
		update keplersc.kdcomismov2 set c11=tipo_operacion,
		c12=asesor_comprador, c13=valuador_comprador, c7=fecha_vale_salida
		where c1=sucursal_id and c8=inventario ;
	
		
		update keplersc.kdipva set c17=tipo_operacion, c14=modelo,
		c21=linea_vehiculo where c1=sucursal_id and c2=inventario ;
	
		update keplersc.kdpedido set c11=tipo_operacion, c42=coach, c10=asesor
		where c1=sucursal_id and c2=inventario ;
	
	
		if modelo <> '' then
		
			update keplersc.kdicom set c39=unidad_traslado, c16=modelo, 
			c19=linea_vehiculo, c40=coach_comprador, c41= asesor_comprador, c42=valuador_comprador,
			c9=fecha_compra where c1=sucursal_id and c2=inventario;
		
			update keplersc.kdinf set c3=modelo where c1=sucursal_id and c2=inventario ;
	 	
			update keplersc.kdlinv set c12=modelo where c1=sucursal_id and c2=inventario ;
		
			update keplersc.kdginv set c7=modelo where c1=sucursal_id and c2=inventario ;
	
		 	update keplersc.kdasig set c3=modelo where c1=sucursal_id and c2=inventario ;
			
		end if;
	
	 	
		resultado := 1;
		mensaje :=  'Cambios guardados correctamente';
		adicionales := '' ;
		return query select resultado, mensaje, adicionales;	

exception
		when others then
			resultado := 0;
			mensaje := 'cambia_tipo_operacion() ' || '['|| sqlstate || '] ' || sqlerrm ;		
			adicionales := '';
			return query select resultado, mensaje, adicionales;	
	
end;
$function$
