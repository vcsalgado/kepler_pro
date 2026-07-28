CREATE OR REPLACE FUNCTION keplersc.ven_pvasinfact_mod(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de definicion de documento
	sucursal_id text = '';	
	inventario text = '';
	k_gastosadmin text = '';
	k_seguro text = '';
	k_garantia text = '';
	k_subsidio text = '';
	k_extra1 text = '';
	k_extra2 text = '';
	k_extra3 text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	inventario := (xpath('//document/k_inventario/text()', dataxml))[1];
	k_gastosadmin := (xpath('//document/k_gastosadmin/text()', dataxml))[1];
	k_seguro := (xpath('//document/k_seguro/text()', dataxml))[1];
	k_garantia := (xpath('//document/k_garantia/text()', dataxml))[1];
	k_subsidio := (xpath('//document/k_subsidio/text()', dataxml))[1];
	k_extra1 := (xpath('//document/k_extra1/text()', dataxml))[1];
	k_extra2 := (xpath('//document/k_extra2/text()', dataxml))[1];
	k_extra3 := (xpath('//document/k_extra3/text()', dataxml))[1];

	update keplersc.kdpedido set c17=k_gastosadmin::numeric, c20=k_seguro::numeric, c19=k_garantia::numeric, 
		c15=k_subsidio::numeric, c43=k_extra1::numeric, c44=k_extra2::numeric, c45=k_extra3::numeric 
		where c1=sucursal_id and c2=inventario; 

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
