CREATE OR REPLACE FUNCTION keplersc.rep_venrepcajtotxtpcbrftodet_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal_id text = '';
	fech_ini text = '';
	fech_fin text = '';
	nivel_detalle text = '';
	gen text;
	nat text;
	gpo text;
	tipo text;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fech_ini := (xpath('//document/fech_ini/text()', dataxml))[1];
	fech_fin := (xpath('//document/fech_fin/text()', dataxml))[1];
	gen := (xpath('//document/gen/text()', dataxml))[1];
	nat := (xpath('//document/nat/text()', dataxml))[1];
	gpo := (xpath('//document/gpo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	--*/

	nat := trim(nat);

	-- Workflow ... 
	strValor := 'YYYY-MM-DD';

	--/*
	expSql := format(
		'
		select E.c1 as sucursal, E.c3, E.c4, E.c5, E.c6, upper(M.c5) as Tipo, 
		(case when E.c2 = ''I'' then E.c10 else (E.c10 * -1) end) as Ingresos 
		, Y.c9 as fecha, Y.c11 as refer, left(Y.c25,25) as nombre 
		, (E.c3 || E.c4 || lpad(E.c5::text,2,''0'') || lpad(E.c6::text,3,''0'') || ''-'' || E.c7) as folio
		/*, ''000001'' as folio*/ 
		from keplersc.kdecaja E 
		inner join keplersc.kdmm M on E.c1 = M.col_sucursal and E.c3 = M.c1 and E.c4 = M.c2 and E.c5 = M.c3 and E.c6 = M.c4 and upper(M.c14) = upper(''S'') 
		inner join keplersc.kdm1 Y on E.c1 = Y.c1 and E.c3 = Y.c2 and E.c4 = Y.c3 and E.c5 = Y.c4 and E.c6 = Y.c5 and E.c7 = Y.c6  
		where 
		E.c9 >= to_date(%2$L,%4$L) and E.c9 <= to_date(%3$L,%4$L) 
		/*E.c9 >= %2$L and E.c9 <= %3$L*/  
		and E.c1 = %1$L and E.c3 = %5$L and E.c4 = %6$L and E.c5 = %7$s and E.c6 = %8$s 
		'
		, sucursal_id,fech_ini,fech_fin, strValor, gen, nat, gpo, tipo);
	--*/

	--expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini';
	--execute format(expSql);
	--select query_to_xml('select * from tmpDoctosDet',false,true,'') into xmlResultado;
	
	--raise notice '%', expSql; 
	
   select query_to_xml(expSql,false,true,'') into xmlResultado;
  
   --raise notice '%', xmlResultado;
  
   return xmlResultado;

end;
$function$
