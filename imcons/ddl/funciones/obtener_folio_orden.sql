CREATE OR REPLACE FUNCTION keplersc.obtener_folio_orden(sucursal text, tipo_orden text, folio_id text)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
declare 
	folio_operacion text;
	strValor text;
	campo_folio text;
	intValor int;
	nombreFolio text;
	lenFolio int;
	consecutivo_folio text;

--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin

	--Obtener tipo de identificador de folio
	select count(*) into intValor from keplersc.param_oper where parametro='Formato contador orden';
	if intValor > 0 then
		select valor into strValor from keplersc.param_oper where parametro='Formato contador orden';
		if strValor = 'PORTIPO' then
			nombreFolio=tipo_orden || '-' || folio_id;
		else 
			nombreFolio=folio_id;
		end if;
	else
		nombreFolio=folio_id;
	end if;

	--Realizar un UPDATE para tomar la tabla como exclusiva mientras se calcula el nuevo folio
	update keplersc.sqliov set c4 = c4 where col_sucursal=sucursal and c1=nombreFolio;
	select c4 into consecutivo_folio from keplersc.sqliov where col_sucursal=sucursal and c1=nombreFolio;

	if(consecutivo_folio is null) then
		raise exception 'Folio no encontrado %', nombreFolio;
	end if;

	lenFolio = length(consecutivo_folio);
	consecutivo_folio := consecutivo_folio::int + 1;
	strValor := lpad(consecutivo_folio,lenFolio,'0');	

	update keplersc.sqliov set c4 = strValor where col_sucursal=sucursal and c1=nombreFolio;

	folio_operacion:=strValor;

	resultado := '1';
	mensaje := folio_operacion;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'obtener_folio_orden(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
