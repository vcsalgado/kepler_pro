CREATE OR REPLACE FUNCTION keplersc.ser_alta_orden(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Registro de la orden. Resuelve: ALTA_ORDEN y ejecuta: ALTA_ORDEN_FACTURA,ALTA_ORDEN_NOTA_CREDITO,ALTA_ORDEN_VEN_TALL,
--ORD_GUARDA_COSTO_INVENTARIO, ORDEN_ALTA_NOTA  
--Autor: Miriam Santana
--Fecha: 21/10/2022
	tipo text;
	clave_cteprov text;
	correo text;
begin
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];
	correo := (xpath('//document/k_correo/text()', dataxml))[1];
	--CALL ALTA_ORDEN_FACTURA
	select * into resultado, mensaje, adicionales from keplersc.ser_alta_orden_factura(dataxml,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 

    --CALL ALTA_ORDEN_NOTA_CREDITO 
	select * into resultado, mensaje, adicionales from keplersc.ser_alta_orden_nota_credito(dataxml,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 

	--CALL ALTA_ORDEN_VEN_TALL
	select * into resultado, mensaje, adicionales from keplersc.ser_alta_orden_ven_tall(dataxml,xmlkdm1,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 

	--CALL ORD_GUARDA_COSTO_INVENTARIO
	select * into resultado, mensaje, adicionales from keplersc.ser_ord_guarda_costo_inventario(dataxml,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 
  
	--Actualiza correo del cliente para movimientos de contado
	if tipo = '1' then
		update keplersc.kdud set c11=correo
			where c2=clave_cteprov;
	end if;
	
 	--CALL ORDEN_ALTA_NOTA
 	select * into resultado, mensaje, adicionales from keplersc.ser_orden_alta_nota(dataxml,xmlkdmm,folio_operacion); 
	if resultado = '0' then
		raise exception '%',mensaje;
	end if; 
 
	   
exception
	when others then
		resultado := 0;
		mensaje := 'ser_alta_orden() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
