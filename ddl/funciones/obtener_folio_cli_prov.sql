CREATE OR REPLACE FUNCTION keplersc.obtener_folio_cli_prov(tipo text)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: obtiene folio para cliente y proveedor
--Autor: Luis Leal
--Fecha: 08/12/2022
--Bitacora de cambios

declare 	

	ultimo_folio text;
	nuevo_folio text;

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin

	if tipo = 'C' then
		select max(c2) into ultimo_folio from keplersc.kdud where substring(c2,2,1) <> 'A';		--MSS 230924: No considerar clave de cliente CA00001 
	end if;
	
	if tipo = 'P' then
		select max(c2) into ultimo_folio from keplersc.kdxd ;
	end if;
	
	ultimo_folio := right(ultimo_folio, 6);
	nuevo_folio := ultimo_folio::int + 1;
	nuevo_folio := concat(tipo,nuevo_folio); 

	--Retorno tipo tabla
	resultado := '1';
	mensaje := nuevo_folio;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'obtener_folio_cli_prov(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
