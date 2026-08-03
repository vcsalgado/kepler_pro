CREATE OR REPLACE FUNCTION keplersc.cxcp_movtos_docto(dataxml xml, documento text)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Obtiene en formato XML los movimientos relacionados con un documento CxC o CxP
--Autor: Víctor Salgado
--Fecha: 29/10/2021
--Bitacora de cambios
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	cliente_prov text = '';
	--documento text = '';

	--Variables de proceso
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	cliente_prov := (xpath('//document/cliente_prov/text()', dataxml))[1];

	expSql := format('select xe.c5||xe.c6||lpad(xe.c7::text,2,''0'')||lpad(xe.c8::text,3,''0'')||''-''||xe.c9 as movto,
			mm.c5 as movto_desc,
			(case when xe.c6=''D'' then xe.c13 else 0 end) as movto_cargo,	
			(case when xe.c6=''A'' then xe.c13 else 0 end) as movto_abono 
			from keplersc.kduxe xe, keplersc.kdmm mm
			where xe.c1=mm.col_sucursal and xe.c5 = mm.c1 and xe.c6=mm.c2 and xe.c7=mm.c3 and xe.c8=mm.c4
			and xe.c1=%1$L and xe.c2=%2$L and xe.c3=%3$L',sucursal_id,cliente_prov,documento);

	select query_to_xml(expSql, false, true, '') into xmlResultado ;
	return xmlResultado;
exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
