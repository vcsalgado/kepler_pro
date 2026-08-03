CREATE OR REPLACE FUNCTION keplersc.valida_folio_orden_ingresado(folio_ingresado text)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--05/12/24 Miriam Santana: Agregar sucursal

declare 	
	sucursal_id	text= '';
	lenFolio int = 0;
	ctd_folio_repetido int;

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin
	sucursal_id := split_part(folio_ingresado, '.', 1);
	folio_ingresado := split_part(folio_ingresado, '.', 2);

	lenFolio = length(folio_ingresado);

	if lenFolio <> 10 then
		raise exception '%' , 'La longitud del folio debe ser de 10 caracteres.';
	end if;	

	select count(*) into ctd_folio_repetido from keplersc.kdord where c3=folio_ingresado;

	while ctd_folio_repetido > 0 loop
		
		folio_ingresado := folio_ingresado::int + 1;
	
		folio_ingresado := lpad(folio_ingresado,lenFolio,'0');
		
		select count(*) into ctd_folio_repetido from keplersc.kdord where c1=sucursal_id and c3=folio_ingresado;
		
	end loop;
	
	--Retorno tipo tabla
	resultado := '1';
	mensaje := folio_ingresado;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'valida_folio_orden_ingresado(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
