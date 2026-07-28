CREATE OR REPLACE FUNCTION keplersc.rep_venrepcajtotxtpcbrfto_sel(dataxml xml)
 RETURNS TABLE(suc text, gen text, nat text, gpo text, tipo text, desctipo text, sum_importe text, detalle xml)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal_ini text = '';
	sucursal_fin text = '';
	fech_ini text = '';
	fech_fin text = '';
	nivel_detalle text = '';


	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal_ini := (xpath('//document/sucursal_ini/text()', dataxml))[1];
	sucursal_fin := (xpath('//document/sucursal_fin/text()', dataxml))[1];
	fech_ini := (xpath('//document/fech_ini/text()', dataxml))[1];
	fech_fin := (xpath('//document/fech_fin/text()', dataxml))[1];
	nivel_detalle := (xpath('//document/nivel_detalle/text()', dataxml))[1];
	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		suc text,
		gen text,
		nat text,
		gpo text,
		tipo text, 
		desctipo text,
		sum_importe text,
		detalle xml
	);

	-- Workflow ... 
	--/*
	xmlReqDoctos:='<document><sucursal_id>%1$s</sucursal_id><fech_ini>%2s</fech_ini><fech_fin>%3s</fech_fin><gen>%4$s</gen><nat>%5s</nat><gpo>%6$s</gpo><tipo>%7$s</tipo></document>';
	--*/

	--raise notice '%', nivel_detalle;

	--/*
	----expSql= format('
	insert into tmpDoctos 
	select tres.*,  
		case when nivel_detalle = 'N' then 
			''::xml
		else
			(select * from keplersc.rep_venrepcajtotxtpcbrftodet_sel(format(xmlReqDoctos,tres.c1,fech_ini,fech_fin,tres.c3,tres.c4,tres.c5,tres.c6)::xml))
			--'Entro'::xml
		end as detalle 	
	from (
	
	
		select E.c1, E.c3, E.c4, E.c5, E.c6, upper(M.c5) as Tipo, sum(case when E.c2 = 'I' then E.c10 else (E.c10 * -1) end) as Ingresos 
		from keplersc.kdecaja E 
		inner join keplersc.kdmm M on E.c3 = M.c1 and E.c4 = M.c2 and E.c5 = M.c3 and E.c6 = M.c4 and upper(M.c14) = upper('S')
		where 
			( E.c9 >= to_date(fech_ini/*'2022-04-01'*/,'YYYY-MM-DD') and E.c9 <= to_date(fech_fin/*'2022-04-30'*/,'YYYY-MM-DD') ) 
			and ( E.c1 >= sucursal_ini and E.c1 <= sucursal_fin )  
		group by E.c1, E.c3, E.c4, E.c5, E.c6, upper(M.c5)
		
	) as tres
	
	order by tres.c1, tres.c3, tres.c4, tres.c5, tres.c6;
	--*/

	-- expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini'; 
	--raise notice '%', expSql;
	--execute format(expSql);

	return query select * from tmpDoctos;

END;
$function$
