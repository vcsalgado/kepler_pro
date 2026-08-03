CREATE OR REPLACE FUNCTION keplersc.obtener_folio_poliza(folio_id text)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
declare 
	folio_operacion text;
	strValor text;
	campo_folio text;

--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin

	--Realizar un UPDATE para tomar la tabla como exclusiva mientras se calcula el nuevo folio
	update keplersc.sqliov set c4 = c4 where c1 = folio_id;
	select c4 into strValor from keplersc.sqliov where c1 = folio_id;

	if(strValor is null) then
		--TODO, crear folio automatico
		raise exception 'Folio no encontrado %', folio_id;
	end if;
	strValor := (strValor::int + 1)::text;

	update keplersc.sqliov set c4 = strValor where c1=folio_id;

	folio_operacion:=strValor;

	resultado := '1';
	mensaje := folio_operacion;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'obtener_folio_poliza(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
