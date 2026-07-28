CREATE OR REPLACE FUNCTION keplersc.cxcp_kduxe_baja(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja de Cuentas por Cobara y/o Pagar en kduxe
--Autor: Miriam Santana
--Fecha: 22/08/2022
--Bitacora de cambios
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

begin
	--Valores de XML
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Resuelve K75:BAJA_CXCP que es una baja de una CXCP_ALTA_SINMOV y CXCP_ALTA_CONMOV
	delete from keplersc.kduxe 
		where c1=sucursal_id and c5=genero and c6=naturaleza and c7=grupo::integer and c8=tipo_clave::integer and c9=folio_operacion::text;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_kduxe_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
