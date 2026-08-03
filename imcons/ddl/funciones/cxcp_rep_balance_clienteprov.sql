CREATE OR REPLACE FUNCTION keplersc.cxcp_rep_balance_clienteprov(dataxml xml)
 RETURNS TABLE(clienteprov_clave text, clienteprov_desc text, cargos numeric, abonos numeric, saldo numeric, doctos xml)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Genera la informacion para el reporte de balance de proveedores OXRB
--Autor: Victor Salgado
--Fecha: 29/10/2021
--Bitacora de cambios
declare
	--Variables de definicion de documento
	sucursal_id text = '';
	clienteprov_ini text = '';
	clienteprov_fin text = '';
	nivel_detalle text = '';
	inc_saldados text = '';
	tipo text = '';
	

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';
	xmlReqDoctos text = '';

	xmlResultado xml;

	--Variables de retorno

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	clienteprov_ini := (xpath('//document/clienteprov_ini/text()', dataxml))[1];
	clienteprov_fin := (xpath('//document/clienteprov_fin/text()', dataxml))[1];
	nivel_detalle := (xpath('//document/nivel_detalle/text()', dataxml))[1];
	inc_saldados := (xpath('//document/inc_saldados/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];

--	raise notice '%', tipo;

	
	xmlReqDoctos:='<document><sucursal_id>%1$s</sucursal_id><cliente_prov>%2s</cliente_prov><nivel_detalle>%3$s</nivel_detalle><inc_saldados>%4$s</inc_saldados><tipo>%5$s</tipo><docto>%7s</docto></document>';		
--raise notice '%', xmlReqDoctos;

	if tipo = 'cliente' then
		return query
		select xd.c2::text as clienteprov_clave, xd.c3::text as clienteprov_desc,
		sum(xg.c6) as cargos, sum(xg.c7) as abonos,
		sum(xg.c6) - sum(xg.c7) as saldo,
		case when nivel_detalle='1' then
			''::xml
		else
			(select * from keplersc.cxcp_doctos_clienteprov(format(xmlReqDoctos,sucursal_id,xd.c2,nivel_detalle,inc_saldados,tipo,'')::xml))
		end as doctos	
		from keplersc.kdud as xd, keplersc.kduxg as xg 
		where xd.c2 = xg.c3
		and xg.c1=sucursal_id and xg.c3 between clienteprov_ini and clienteprov_fin 
		and case when inc_saldados='N' then xg.c7 <> xg.c6 else xg.c7 = xg.c7 end
		group by xd.c2, xd.c3;	
	else
		return query
		select xd.c2::text as clienteprov_clave, xd.c3::text as clienteprov_desc,
		sum(xg.c6) as cargos, sum(xg.c7) as abonos,
		sum(xg.c7) - sum(xg.c6) as saldo,
		case when nivel_detalle='1' then
			''::xml
		else
			(select * from keplersc.cxcp_doctos_clienteprov(format(xmlReqDoctos,sucursal_id,xg.c3,nivel_detalle,inc_saldados,tipo,'')::xml))	
		end as doctos	
		from keplersc.kdxd as xd, keplersc.kduxg as xg 
		where xd.c2 = xg.c3
		and xg.c1=sucursal_id and xg.c3 between clienteprov_ini and clienteprov_fin 
		and case when inc_saldados='N' then xg.c7 <> xg.c6 else xg.c7 = xg.c7 end
		group by xd.c2, xd.c3, xg.c3;
	end if;

exception
	when others then
		raise exception '%', sqlerrm;	
end;
$function$
