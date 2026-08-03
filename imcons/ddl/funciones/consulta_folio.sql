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
	sucursal_id text;
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
	sucursal_id := coalesce((xpath('//document/k_sucn/r1/text()', dataxml))[1]::text,
				(xpath('//document/k_sucN/r1/text()', dataxml))[1]::text)::text;
	folio_id := coalesce((xpath('//document/folio_id/text()', dataxml))[1]::text,'')::text;
	uen := coalesce((xpath('//document/uen/text()', dataxml))[1]::text,'X')::text;
	genero := coalesce((xpath('//document/k_tipon/r1/text()', dataxml))[1]::text,'')::text;
	naturaleza := coalesce((xpath('//document/k_tipon/r2/text()', dataxml))[1]::text,'')::text;
	grupo := coalesce((xpath('//document/k_tipon/r3/text()', dataxml))[1]::text,'')::text;
	tipo_clave := coalesce((xpath('//document/k_tipon/r4/text()', dataxml))[1]::text,'')::text;

	if sucursal_id='' then
		raise exception 'No se envio sucursal';
	end if;
		
	folio_id:=upper(folio_id);
	if not folio_id ~ '[A-Z]' then
		if genero <> '' and naturaleza <> '' and grupo <> '' and tipo_clave <> '' then 
			folio_id := lpad(folio_id,7,'0');
		
			select c80 into genera_cfd from keplersc.kdmm where col_sucursal=sucursal_id and c1=genero and c2=naturaleza and c3=grupo::numeric  and c4=tipo_clave::numeric;
	raise notice 'genera_cfd:%',genera_cfd;	
			if genera_cfd = 'S' then
				select c6 into letras_sat from keplersc.kdcfdsersucdoc where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::numeric and c5=tipo_clave::numeric;
raise notice 'letras_sat:%',letras_sat;
				if not found then
					letras_sat := 'XX';
				end if;		
			else
				letras_sat := 'XX';
			end if;	
raise notice 'letras_sat:%',letras_sat;			
			folio_id := concat(substring(uen,1,1), letras_sat ,folio_id);
		else
			folio_id := lpad(folio_id,10,'0');
		end if;
	end if;
raise notice 'folio_id:%',folio_id;
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
