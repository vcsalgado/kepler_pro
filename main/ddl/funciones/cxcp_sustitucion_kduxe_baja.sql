CREATE OR REPLACE FUNCTION keplersc.cxcp_sustitucion_kduxe_baja(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja de Cuentas por Cobara y/o Pagar en kduxe de una sustituciÃ³n
--			   Resuelve K75:CXCP_SUSTITUCION
--Autor: Miriam Santana
--Fecha: 15/12/2022
--Bitacora de cambios
	--Variables de definicion de documento
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	foliodocto_anx text;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	totalReg int;

begin
	--Valores de XML de un documento a anexar W36..W39  -->k_natdocto,k_gpodocto,k_tipodocto,k_foliodocto
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_natdocto/text()', dataxml))[1];
	grupo := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	foliodocto_anx := (xpath('//document/k_foliodocto/text()', dataxml))[1];

	delete from keplersc.kduxe 
		where c1=sucursal_id and c5=genero and c6=naturaleza and c7=grupo::integer and c8=tipo_clave::integer and c9=foliodocto_anx;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cxcp_sustitucion_kduxe_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
	
end;
$function$
