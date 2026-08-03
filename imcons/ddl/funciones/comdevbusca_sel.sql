CREATE OR REPLACE FUNCTION keplersc.comdevbusca_sel(dataxml xml)
 RETURNS TABLE(encabezado xml, detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: 
--Obtiene en formato XML el encabezado y detalle de una sola devolucion
--Autor: Equipo desarrollo MS,JM,GM,VS
--Fecha: 22/Jun/22
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
	expSql text = '';
	espacio text = ' ';
	cero text = '0';

	--Variables de retorno
	xmlEncabezado xml;
	xmlDetalle xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	--proveedor_id := (xpath('//document/proveedor_id/text()', dataxml))[1];
	--referencia := (xpath('//document/referencia/text()', dataxml))[1];
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

	-- NEW 20220722
	select c10, c11 into proveedor_id, referencia from keplersc.kdm1 
	where c2 = genero and c3 = naturaleza and c4 = grupo::integer and c5 = tipo::integer and c6 = folio;
	
	-- ENCABEZADO ... 
	expSql= format(
	-- Se cambiaron los campos de los totales para que se pasen a la SCR de K-80
	'
	select tuxg.c3 as k_clave/*k_claveprov*/, txd.c3 as nombre, tdm1.c6/*tuxg.c4*/ as documento, tdm1.c9/*tuxg.c11*/ as k_fecha/*fecha_exp*/, 
	tdm1.c17 as k_plazo, tdm1.c18 as k_vence, tdm1.c30 as k_cond, tdm1.c24|| %7$L || tdm1.c25 || %7$L || tdm1.c26 as k_coment,
	tdm1.c16 as k_monto/*k_monto_compra*/, tdm1.c14 as k_iva/*k_iva_compra*/, tdm1.c16 - tdm1.c14 as k_subtotal, 
	round((tdm1.c14/(tdm1.c16 - tdm1.c14))*100,2) as k_porciva, tdm1.c11 as k_refer 
	from keplersc.kdm1 tdm1 
		inner join keplersc.kduxe tuxe 
		on tdm1.c1 = tuxe.c1 and tdm1.c6 = tuxe.c9 and tdm1.c10 = tuxe.c2 
		and /*lpad(tdm1.c11,10,%1$L)*/ tdm1.c11 = tuxe.c3 
		and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8 
		inner join keplersc.kduxg tuxg on tuxg.c1 = tuxe.c1 and tuxg.c4 = /*tuxe.c9*/tuxe.c3 and tuxg.c3 = tuxe.c2 
		inner join keplersc.kdxd txd on txd.c2 = tuxg.c3  
	where tuxe.c5 = %1$L and tuxe.c6 = %2$L and tuxe.c7 = %3$s and tuxe.c8 = %9$s   
	and tuxe.c9 = %10$L 	'
	,genero,naturaleza,grupo,sucursal_id,proveedor_id,referencia,espacio,cero,tipo,folio);	
	
	--raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlEncabezado;
	--raise notice '%', xmlEncabezado;
	
	-- DETALLE ...
	expSql= format(
	'
	select tdm1.c1 as sucursal, tdm2.c10 as k_descr, tdm2.c8 as k_parte, tdm2.c9 as k_q/*k_qc*/, tdm2.c11 as k_unidad, tdm2.c12 as k_precio/*k_pc*/ 
	, tdm2.c13 as k_monto/*k_importe*/, tdm2.c17 as ivaperce, tdm2.c27 as costovtapartida, tdm2.c28 as k_partesel 
	, /*lpad(tdm1.c11,10,%8$L)*/ tdm1.c11 as refer, tdm1.c6 as folio 
	, tdm2.c7 as partida, tdm1.c1 as suc, tdm1.c10 as prov, tuxg.c4 as Factura
	from keplersc.kdm1 tdm1 
		inner join keplersc.kdm2 tdm2 on tdm1.c1 = tdm2.c1 and tdm1.c6 = tdm2.c6 
		and tdm1.c2 = tdm2.c2 and tdm1.c3 = tdm2.c3 and tdm1.c4 = tdm2.c4 and tdm1.c5 = tdm2.c5
		inner join keplersc.kduxe tuxe 
		on tdm1.c1 = tuxe.c1 and tdm1.c6 = tuxe.c9 and tdm1.c10 = tuxe.c2 
		and /*lpad(tdm1.c11,10,%1$L)*/ tdm1.c11 = tuxe.c3 
		and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8 
		inner join keplersc.kduxg tuxg on tuxg.c1 = tuxe.c1 and tuxg.c4 = /*tuxe.c9*/tuxe.c3 and tuxg.c3 = tuxe.c2 
		inner join keplersc.kdxd txd on txd.c2 = tuxg.c3  
	where tuxe.c5 = %1$L and tuxe.c6 = %2$L and tuxe.c7 = %3$s and tuxe.c8 = %9$s   
	and tuxe.c9 = %10$L 
	order by tdm1.c1, tdm1.c6, tdm2.c7 '
	,genero,naturaleza,grupo,sucursal_id,proveedor_id,referencia,espacio,cero,tipo,folio);	
	
	--raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlDetalle;
	--raise notice '%', xmlDetalle;

	insert into tmpResultados(encabezado,detalle) values(xmlEncabezado,xmlDetalle);
	
	return query select * from tmpResultados;

END;
$function$
