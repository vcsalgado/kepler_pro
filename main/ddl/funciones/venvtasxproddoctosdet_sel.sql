CREATE OR REPLACE FUNCTION keplersc.venvtasxproddoctosdet_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare
	--Variables del xml 
	clave_prod text='';
	fecha_ini text='';
	fecha_fin text = '';
	
	--Variables de procceso
	expSql text = '';

	resXml xml;
	
begin
		expsql=Format('select ');
	return resXml;
END;
$function$
