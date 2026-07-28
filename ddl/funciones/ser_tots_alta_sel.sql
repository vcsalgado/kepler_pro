CREATE OR REPLACE FUNCTION keplersc.ser_tots_alta_sel(dataxml xml)
 RETURNS TABLE(encabezado xml, detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML el encabezado y detalle de los movimientos de TOTs
--Autor: Miriam Santana
--Fecha: 15/Ago/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	proveedor_id text = '';
	referencia text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlEncabezado xml;
	xmlDetalle xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	proveedor_id := (xpath('//document/proveedor_id/text()', dataxml))[1];
	referencia := (xpath('//document/referencia/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()', dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	folio := (xpath('//document/folio/text()', dataxml))[1];

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml,
		detalle xml
	);
expSql= format('
select dm1.C9 as k_fecha, dm1.c69 as k_hora, dm1.C10 as k_clave, dm1.C11 as k_refer,dm1.C16-dm1.c14 as k_subtotal,dm1.c14 as k_iva, 
dm1.C16 as k_monto,round((dm1.c14/(dm1.c16 - dm1.c14))*100,2) as k_porciva,
xd.c10 as k_rfc, xd.c3 as k_nombreprov, xd.c4 as k_calleprov, xd.c5 as k_coloniaprov, xd.c6 as k_poblacionprov, xd.c27 as k_cpprov,
concat(regexp_replace(dm1.c24,''\r|\n'','' '', ''g''),'' '',dm1.c25,'' '',dm1.c26) as k_coment
from keplersc.kdm1 dm1 inner join keplersc.kdxd xd on xd.c2 = dm1.c10 
where dm1.c1 = %1$L and dm1.c2 = %2$L and dm1.c3 = %3$L and dm1.c4 = %4$s and dm1.c5 = %5$s and dm1.c6 = %6$L  
',sucursal_id,genero,naturaleza,grupo,tipo,folio);	

select query_to_xml(expSql,false,true,'') into xmlEncabezado;

expSql= format('
select tot.c2 as k_tipo_orden, mar.c3 as k_desc_tipo, tot.c3 as k_num_orden, tot.c4 as k_punto, pun.C8 as k_desc_punto, tot.c10 as k_descriptot,tot.c11 as k_costo, tot.c16 as k_precio
from keplersc.kdtot tot 
inner join keplersc.kdm1 dm1 on dm1.C1=tot.c1 and dm1.C2=tot.c5 and dm1.c3=tot.c6 and dm1.c4 = tot.c7 and dm1.c5= tot.c8 and dm1.c6 = tot.c9
inner join keplersc.kdmargen mar on mar.c1=tot.c2
inner join keplersc.kdpun pun on pun.c1=dm1.c1 and pun.c2=tot.c2 and pun.c3=tot.c3 and pun.c4=tot.c4
where dm1.c1 = %1$L and dm1.c2 = %2$L and dm1.c3 = %3$L and dm1.c4 = %4$s and dm1.c5 = %5$s and dm1.c6 = %6$L  
',sucursal_id,genero,naturaleza,grupo,tipo,folio);

raise notice '%', expSql;
select query_to_xml(expSql,false,true,'') into xmlDetalle;

insert into tmpResultados(encabezado,detalle) 
	values(xmlEncabezado,xmlDetalle);

return query select * from tmpResultados;

END;
$function$
