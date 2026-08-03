CREATE OR REPLACE FUNCTION keplersc.invlib_alta_nota_descuento(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Luis Leal 05/01/2023
	
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	fecha_operacion text = '';
	inventario text ='';
	clave_cli text ='';
	iva numeric;
	importe numeric;
	descuento numeric = 0;

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INV_NOTA_DESCUENTO
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	clave_cli := coalesce((xpath('//document/k_clave/text()', dataxml))[1]::text,'0')::text;
	iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	
	delete from keplersc.kdncred where c1=sucursal_id and c2=inventario and c3=genero and c4=naturaleza and c5=grupo::numeric and c6=tipo_clave::numeric;

	insert into keplersc.kdncred(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11)
	values(sucursal_id, inventario, genero,naturaleza,grupo::numeric,tipo_clave::numeric, folio_operacion, fecha_operacion::date ,iva,importe, 10);

	select c30 into descuento from keplersc.kdpedido where c1=sucursal_id and c2=inventario;

	if naturaleza = 'A' then
		descuento := descuento + (importe-iva);
	else
		descuento := descuento - (importe-iva);
	end if;

	update keplersc.kdpedido set c30=descuento where c1=sucursal_id and c2=inventario;


	--call invlib_inv_status(:dataxml, :xmlkdmm) 			
	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
	
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_alta_nota_descuento() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
