CREATE OR REPLACE FUNCTION keplersc.rep_vencomis_quin_sel(dataxml xml)
 RETURNS TABLE(suc text, anio text, mes text, vendedor text, nombre text, esquema text, base text, net_q1 text, net_q2 text, total_comis text)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal text = '';
	anio text = '';
	mes text = '';
	vend_ini text = '';
	vend_fin text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal := (xpath('//document/sucursal/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];
	vend_ini := (xpath('//document/vend_ini/text()', dataxml))[1];
	vend_fin := (xpath('//document/vend_fin/text()', dataxml))[1];
	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		suc text, 
		anio text, 
		mes text, 
		vendedor text, 
		nombre text, 
		esquema text, 
		base text, 
		net_q1 text, 
		net_q2 text, 
		total_comis text 
	);

	-- Workflow ... 
	--/*
	--xmlReqDoctos:='<document><sucursal>%1$s</sucursal><vendedor>%2s</vendedor><anio>%3s</anio><mes>%4$s</mes></document>';

	--*/

	--raise notice '%', nivel_detalle;

	--/*
	----expSql= format('
	insert into tmpDoctos 
	select 
		tC.suc, tC.anio, tC.mes, tC.vendedor, tC.nombre, tC.esquema 
		, tC.base 
		, case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end as net_q1
		, case when ( tC.tot_comis - tC.base - (case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end) ) < 0 then 0 
		  else ( tC.tot_comis - tC.base - (case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end) ) end as net_q2	
		, (  (
			case when ( tC.tot_comis - tC.base - (case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end) ) < 0 then 0 
		    else ( tC.tot_comis - tC.base - (case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end) ) end
		  ) + ( case when (tC.q1 - tC.base) < 0 then 0 else (tC.q1 - tC.base) end )  ) as total_comis
	from (
		select  tR.suc, tR.anio, tR.mes, tR.vendedor, tR.nombre, tR.esquema 
			, max(tR.basevendedor) as base 
			, sum(case when tR.quincena = 1 then tot_comis else 0 end) as Q1
			, ( sum(case when tR.quincena = 2 then tot_comis else 0 end) - sum(case when tR.quincena = 1 then tot_comis else 0 end) ) as Q2
			, sum(case when tR.quincena = 2 then tot_comis else 0 end) as tot_comis 
		from (
			select 
				C.c1 as suc, C.c2 as anio, C.c3 as mes, C.c4 as Quincena, C.c5 as vendedor, V.c3 as nombre, V.c8 esquema
				, case when C.c6 = 0 then 'Venta' else case when C.c6 = 10 then 'Toma' else case when C.c6 = 20 then 'Toma < 30 dias' else 'Unknown' end end end as tipo 
				, case when C.C9 = 0 then 'Alta' else 'Baja' end as ab 
				, C.c38 as tot_comis, (H.c3 + H.c4 + H.c5) /** -1*/ as basevendedor 
			from keplersc.kdcomisquincena C 
			inner join keplersc.kduv V on V.c1 = C.c1 and V.c2 = C.c5 
			inner join keplersc.kdvesq H on H.c1 = V.c8  
			where C.c1 = sucursal and C.c2 = anio and C.c3 = mes and C.c6 < 30 
				and ( C.c5 >= vend_ini and C.c5 <= vend_fin )
		) tR 
		group by tR.suc, tR.anio, tR.mes, tR.vendedor, tR.nombre, tR.esquema 
		order by tR.suc, tR.anio, tR.mes, tR.vendedor
	) tC;
			
	--*/

	-- expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini'; 
	--raise notice '%', expSql;
	--execute format(expSql);

	return query select * from tmpDoctos;

END;
$function$
