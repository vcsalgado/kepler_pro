CREATE OR REPLACE FUNCTION keplersc.gen_selectgeneral(expsql text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
	declare xmlResult xml;
	begin
		select query_to_xml(expSql, true, false, '') into xmlResult;
		return xmlResult;
	END;
$function$
