CREATE OR REPLACE FUNCTION keplersc.consulta_folio(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, valores text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: forma folio documento
--Autor: Luis Leal
--Fecha: 23/11/2022
--Bitacora de cambios
declare 
	folio_id text;
	uen text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	letras_sat text;
	genera_cfd text;

	--Variables de retorno
	resultado text;
	mensaje text;
	valores text;

begin

	folio_id := coalesce((xpath('//document/folio_id/text()', dataxml))[1]::text,'')::text;
	uen := coalesce((xpath('//document/uen/text()', dataxml))[1]::text,'X')::text;
	genero := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'')::text;
	naturaleza := coalesce((xpath('//document/k_tipon/r2/text()', dataxml))[1]::text,'')::text;
	grupo := coalesce((xpath('//document/k_tipon/r3/text()', dataxml))[1]::text,'')::text;
	tipo_clave := coalesce((xpath('//document/k_tipon/r4/text()', dataxml))[1]::text,'')::text;
		
	folio_id:=upper(folio_id);
	if not folio_id ~ '[A-Z]' then
		if genero <> '' and naturaleza <> '' and grupo <> '' and tipo_clave <> '' then 
			folio_id := lpad(folio_id,7,'0');
		
			select c80 into genera_cfd from keplersc.kdmm where c1=genero and c2=naturaleza and c3=grupo::numeric  and c4=tipo_clave::numeric;
			if genera_cfd = 'S' then
				select c6 into letras_sat from keplersc.kdcfdsersucdoc where c2=genero and c3=naturaleza and c4=grupo::numeric and c5=tipo_clave::numeric;
				if not found then
					letras_sat := 'XX';
				end if;		
			else
				letras_sat := 'XX';
			end if;	
			
			folio_id := concat(substring(uen,1,1), letras_sat ,folio_id);
		else
			folio_id := lpad(folio_id,10,'0');
		end if;
	end if;

	--Retorno tipo tabla
	resultado := '1';
	mensaje := folio_id;
	valores:= '';
	return query select resultado, mensaje, valores;

EXCEPTION
	WHEN others then
		--Retorno tipo tabla
		resultado := '0';
		mensaje := 'consulta_folio(): ' || sqlerrm;
		valores:= '';
		return query select resultado, mensaje, valores;
end;
$function$
