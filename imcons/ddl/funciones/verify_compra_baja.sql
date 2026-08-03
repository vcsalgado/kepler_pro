CREATE OR REPLACE FUNCTION keplersc.verify_compra_baja(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Realiza validacion de bajas de compras
--Autor: Luis Leal
--Fecha: 22/02/2023
--Bitacora de cambios
	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	referencia text = '';
	clave_cteprov text = '';
	cargos decimal;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

begin 	
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()', dataxml))[1];
	clave_cteprov := (xpath('//document/k_clave/text()', dataxml))[1];

	select c6 into cargos from keplersc.kduxg 
	where c1=sucursal_id and c2=genero and c3=clave_cteprov and c4=referencia and c5=1;

	if cargos > 0 then
		raise exception 'La COMPRA ya tiene un CHEQUE, Imposible dar de baja';
	end if;
		
	resultado := 1;
	mensaje := '';
	adicionales := '';
	
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := '0';
		mensaje := 'verify_compra_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

	
end;
$function$
