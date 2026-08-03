CREATE OR REPLACE FUNCTION keplersc.invlib_alta_subsidio(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Autor: Luis Leal 06/01/2023
	
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
	subsidio numeric = 0;

	resultado text;
	mensaje text;
	adicionales text;
begin
	--Resuelve INV_SUBSIDIO
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	inventario := upper((xpath('//document/k_inventario/text()', dataxml))[1]::text);	
	iva := coalesce((xpath('//document/k_iva/text()',dataxml))[1]::text,'0')::text;
	importe := coalesce((xpath('//document/k_monto/text()',dataxml))[1]::text,'0')::text;
	
	select c15 into subsidio from keplersc.kdpedido where c1=sucursal_id and c2=inventario;

	if naturaleza = 'A' then
		subsidio := subsidio + (importe-iva);
	else
		subsidio := subsidio - (importe-iva);
	end if;

	update keplersc.kdpedido set c15=subsidio where c1=sucursal_id and c2=inventario;


	--call invlib_inv_status(:dataxml, :xmlkdmm) 			
	select * into resultado, mensaje, adicionales from keplersc.invlib_inv_status(dataxml,xmlkdmm);
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'invlib_alta_subsidio() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
