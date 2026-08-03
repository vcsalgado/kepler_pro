CREATE OR REPLACE FUNCTION keplersc.venrepvtasxprod_sel(dataxml xml)
 RETURNS TABLE(clave_prod text, desc_prod text, folios xml)
 LANGUAGE plpgsql
AS $function$
declare
	expSql text = '';
begin
	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		clave_prod text,
		desc_prod text,
		folios xml
	);
	expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini';
	execute format(expSql);
	return query select t1.clave_prod, t1.desc_prod, t1.folios from tmpDoctos t1;
END;
$function$
