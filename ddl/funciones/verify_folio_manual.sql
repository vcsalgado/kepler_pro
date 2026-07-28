CREATE OR REPLACE FUNCTION keplersc.verify_folio_manual(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Valida el folio manual
--Autor: Miriam Santana
--Fecha: 11/10/2024
--Bitacora de cambios
declare 
	folio_operacion text;
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	
	totreg int;	

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin

	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];

	--Hacer validaciones al no. folio
	folio_operacion := coalesce((xpath('//document/k_folio/text()',dataxml))[1]::text,'');
				
	if folio_operacion = '' then
		raise exception 'Falta capturar el Folio, este documento requiere folio manual';
	else		
		--valida longitud del folio
		if length(folio_operacion) > 10 then
			raise exception 'El folio no puede tener mas de 10 caracteres....Verifique';
		end if;
		--valida que no exista
		select count(*) into totreg from keplersc.kdm1
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4 =grupo::integer and c5=tipo::integer and c6=folio_operacion;
			--where c1=sucursal_id and c6=folio_operacion;
		if (totReg > 0) then
			raise exception 'El folio capturado ya existe....Verifique';
		end if;
	end if;
				
	--Retorno tipo tabla
	resultado := '1';
	mensaje := folio_operacion;
	valores:= '';

	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'verify_folio_manual(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
