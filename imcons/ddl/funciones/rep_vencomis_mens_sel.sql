CREATE OR REPLACE FUNCTION keplersc.rep_vencomis_mens_sel(dataxml xml)
 RETURNS TABLE(suc text, anio text, mes text, vendedor text, nombre text, tot_comis text, basevendedor text, net_comis text, utilidad text, c_base text, c_traslado text, c_edad text, c_linea text, c_gastos text, c_seguro text, c_extras text, c_accesorios text, c_semana text, c_total_sub text, c_dcto_tmkt text, detalle xml)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal text = '';
	anio text = '';
	mes text = '';
	vend_ini text = '';
	vend_fin text = '';
	negativos_ceros text = '';
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
	sucursal := (xpath('//document/sucursal/text()', dataxml))[1];
	anio := (xpath('//document/anio/text()', dataxml))[1];
	mes := (xpath('//document/mes/text()', dataxml))[1];
	vend_ini := (xpath('//document/vend_ini/text()', dataxml))[1];
	vend_fin := (xpath('//document/vend_fin/text()', dataxml))[1];
	negativos_ceros := (xpath('//document/negativos_ceros/text()', dataxml))[1];
	nivel_detalle := (xpath('//document/nivel_detalle/text()', dataxml))[1];
	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		suc text,
		anio text,
		mes text,
		vendedor text,
		nombre text,
		tot_comis text,
		BaseVendedor text,
		net_comis text,
		utilidad text,
		c_base text,
		c_traslado text,
		c_edad text,
		c_linea text,
		c_gastos text,
		c_seguro text,
		c_extras text,
		c_accesorios text,
		c_semana text,
		c_total_sub text,
		c_dcto_tmkt text,
		detalle xml
	);

	-- Workflow ... 
	--/*

	xmlReqDoctos:='<document><sucursal>%1$s</sucursal><vendedor>%2s</vendedor><anio>%3s</anio><mes>%4$s</mes></document>';

	--*/

	--raise notice '%', nivel_detalle;

	--/*
	----expSql= format('
	insert into tmpDoctos 
	select tres.*,  
		case when nivel_detalle = 'N' then 
			''::xml
		else
			(select * from keplersc.rep_vencomis_mensdet_sel(format(xmlReqDoctos,tres.suc,tres.vendedor,tres.anio,tres.mes)::xml))
			--'Entro'::xml
		end as detalle 	
	from (
	
		select 
			C.c1 as suc, C.c2 as anio, C.c3 as mes, C.c4 as vendedor, V.c3 as nombre
			, sum(C.C37) as tot_comis
			, max(H.c3 + H.c4 + H.c5) * -1 as basevendedor
			, case when negativos_ceros = 'N' then
				( sum(C.C37) + ( max(H.c3 + H.c4 + H.c5) * -1 ) ) 
			  else
			  	case when ( sum(C.C37) + ( max(H.c3 + H.c4 + H.c5) * -1 ) ) < 0 then 0 
			  		else ( sum(C.C37) + ( max(H.c3 + H.c4 + H.c5) * -1 ) ) end 
			  end as net_comis 
			, sum(C.c19) as utilidad, sum(C.c26) as c_base, sum(C.c27) as c_traslado, sum(C.c28) as c_edad
			, sum(C.c29) as c_linea, sum(C.c30) as c_gastos, sum(C.c31) as c_seguro, sum(C.c32) as c_extras
			, sum(C.c33) as c_accesorios, sum(C.c34) as c_semana, sum(C.c35) as c_total_sub, sum(C.c36) as c_dcto_tmkt
		from keplersc.kdcomisventas C 
		inner join keplersc.kduv V on V.c1 = C.c1 and V.c2 = C.c4 
		inner join keplersc.kdvesq H on H.c1 = V.c8 
		where C.c1 = sucursal and C.c2 = anio and C.c3 = mes and C.c5 < 30 
			and ( C.c4 >= vend_ini and C.c4 <= vend_fin ) 
		group by C.c1, C.c2, C.c3, C.c4, V.c3
		order by C.c1, C.c2, C.c3, C.c4  
			
	) as tres
	order by suc, anio, mes, vendedor;
	--*/

	-- expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini'; 
	--raise notice '%', expSql;
	--execute format(expSql);

	return query select * from tmpDoctos;

END;
$function$
