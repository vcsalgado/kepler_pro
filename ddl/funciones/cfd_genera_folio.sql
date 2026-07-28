CREATE OR REPLACE FUNCTION keplersc.cfd_genera_folio(folio_id text, sucursal_id text, genero text, naturaleza text, grupo text, tipo text)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Genera folio cfd a apartir del folio generado en docdis. Resuelve CFD_GENERA_FOLIO Y CDF_GUARDA_FOLIO
--Autor: Miriam Santana
--Fecha: 28/09/2022

	strValor text;
	strPrefijo text;
	expSql text;
	lenFolio int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin
	strPrefijo = '';
	select c6 into strPrefijo from keplersc.kdcfdsersucdoc
		where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo::integer;
	if found then
		lenFolio = length(folio_id);
		strValor = folio_id;
		if strPrefijo <> '' then
			strValor := right(folio_id,5);
			strValor := strPrefijo || strValor;	
		end if;
	else
		raise exception 'No tiene dado de Alta una Serie para el CFDI, Imposible Continuar';
	end if;
	
	resultado := '1';
	mensaje := strValor;
	valores:= '';
	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'cfd_genera_folio(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;

end;
$function$
