CREATE OR REPLACE FUNCTION keplersc.cxcp_doctos_clienteprov(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
--Descripcion: Obtiene en formato XML los documentos asociados con un cliente o proveedor
--Autor: Víctor Salgado
--Fecha: 29/10/2021
--Bitacora de cambios
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	cliente_prov text = '';
	nivel_detalle text = '';
	inc_saldados text = '';
	tipo text = '';
	tabla text = '';
	naturaleza_1 text;
	naturaleza_2 text;
	docto text ;

	--Variables de proceso
	expSql text = '';
	totalReg numeric = 0;
	xmlReqMovtos text;

	--Variables de retorno
	xmlResultado xml;

begin
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	cliente_prov := (xpath('//document/cliente_prov/text()', dataxml))[1];
	nivel_detalle := (xpath('//document/nivel_detalle/text()', dataxml))[1];
	inc_saldados := (xpath('//document/inc_saldados/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	if tipo = 'cliente' then
		tabla := 'kdud';
		naturaleza_1 := 'D';
		naturaleza_2 := 'A';
	else
		tabla := 'kdxd';
		naturaleza_1 := 'A';
		naturaleza_2 := 'D';
	end if;


	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		factura text,
		documento text,
		expedicion text,
		vencimiento text,
		cargos numeric,
		abonos numeric,
		saldo numeric,
		movtos xml
	);


	expSql := 'insert into tmpDoctos select xe.c3::text as factura, xg.c5::text as documento, xg.c11::text as expedicion, xg.c12::text as vencimiento,
	sum (case when xe.c6=''D'' then xe.c13 else 0 end) as cargos,
	sum (case when xe.c6=''A'' then xe.c13 else 0 end) as abonos,
	sum (case when xe.c6=%1$L then xe.c13 else 0 end) - sum (case when xe.c6=%2$L then xe.c13 else 0 end) as saldo,
	case when %3$L = ''2'' then
	''''::xml
	else
		(select * from keplersc.cxcp_movtos_docto(''<document><sucursal_id>%4$s</sucursal_id><cliente_prov>%6$s</cliente_prov><documento>%8$s</documento></document>'',xg.c4))
	end as movtos 
	from keplersc.kduxe xe, keplersc.%5$s xd, keplersc.kduxg xg
	where xd.c2 = xe.c2 
	and xg.c1 = xe.c1 and xg.c3 = xe.c2 and xg.c4 = xe.c3
	and xg.c1=%4$L and xg.c3 = %6$L 
	and case when %7$L =''N'' then xg.c7 <> xg.c6 else xg.c7 = xg.c7 end
	group by xe.c2,xd.c3,xe.c3,xg.c5,xg.c11,xg.c12,xg.c4
	order by xg.c11';

	expSql := format(expSql, naturaleza_1,naturaleza_2,nivel_detalle,sucursal_id,tabla,cliente_prov,inc_saldados,docto);

	execute format(expSql);
	
select query_to_xml('select * from tmpDoctos', false, true, '') into xmlResultado ;
	return xmlResultado;
exception
	when others then	
		raise exception '%', sqlerrm;	
end;
$function$
