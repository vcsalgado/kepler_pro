CREATE OR REPLACE FUNCTION keplersc.comdevalta_sel(dataxml xml)
 RETURNS TABLE(encabezado xml, detpartidas xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML el encabezado y detalle de partidas de una sola compra
--   para hacer una devolucion sobre esta, se incluye la suma de productos ya devueltos
--   y el inventario actual de cada parte
--Autor: Equipo desarrollo MS,JM,GM,VS
--Fecha: 16/Jun/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	proveedor_id text = '';
	referencia text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';
	espacio text = ' ';
	cero text = '0';
	genU text = 'U';
	genX text = 'X';
	genN text = 'N';
	natA text = 'A';
	natD text = 'D';
	genDev text = 'X';
	natDev text = 'D';
	gpoDev text = '40';

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

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml,
		detalle xml
	);
expSql= format(
'
select uxg.c3 as k_claveprov, xd.c3 as nombre, uxg.c4 as documento, uxg.c11 as fecha_exp, 
  m1.c17 as k_plazo, m1.c18 as k_vence, m1.c30 as k_cond, m1.c24|| %7$L || m1.c25 || %7$L || m1.c26 as k_coment,
  m1.c16 as k_monto_compra, m1.c14 as k_iva_compra, m1.c16 - m1.c14 as k_subtotal_compra, round((m1.c14/(m1.c16 - m1.c14))*100,2) as k_porciva
from keplersc.kduxg uxg inner join keplersc.kdxd xd on xd.c2 = uxg.c3 
inner join keplersc.kduxe xe on uxg.c1 = xe.c1 and uxg.c4 = xe.c3 and uxg.c3 = xe.c2
inner join keplersc.kdm1 m1 on m1.c1=uxg.c1 and m1.c10=uxg.c3 and lpad(m1.c11,10,%8$L) = uxg.c4
  /*new 220721*/and m1.c2 = xe.c5 and m1.c3 = xe.c6 and m1.c4 = xe.c7 and m1.c5 = xe.c8 
where uxg.c2 = %1$L and xe.c6 = %2$L and xe.c7 = %3$s
  and uxg.c5 = 1 and uxg.c10 = 0 and uxg.c1 = %4$L and uxg.c3 = %5$L and uxg.c4=%6$L
',genero,naturaleza,grupo,sucursal_id,proveedor_id,referencia,espacio,cero);	

--raise notice '%', expSql;
select query_to_xml(expSql,false,true,'') into xmlEncabezado;
--raise notice '%', xmlEncabezado;

expSql= format(
'
select tdm1.c1 as sucursal, tdm2.c10 as k_descr, tdm2.c8 as k_parte, tdm2.c9 as k_qc, tdm2.c11 as k_unidad, tdm2.c12 as k_pc  
, tdm2.c13 as k_ic, tdm2.c17 as ivaperce, tdm2.c27 as costovtapartida 
, lpad(tdm1.c11,10,%1$L) as refer, tdm1.c6 as folio 
, tdm2.c7 as partida, tdm1.c1 as suc, tdm1.c10 as prov, tuxg.c4 as Factura
, coalesce(tDev.cantdev,0) as k_qd 
, tInv.existencias as k_qi
from keplersc.kdm1 tdm1
	inner join keplersc.kdm2 tdm2 on tdm1.c1 = tdm2.c1 and tdm1.c6 = tdm2.c6 
		/*220721*/ and tdm1.c2 = tdm2.c2 and tdm1.c3 = tdm2.c3 and tdm1.c4 = tdm2.c4 and tdm1.c5 = tdm2.c5
	inner join keplersc.kduxg tuxg on tdm1.c1 = tuxg.c1 and lpad(tdm1.c11,10,%1$L) = tuxg.c4 and tdm1.c10 = tuxg.c3
	/*220721*/ inner join keplersc.kduxe tuxe on tuxg.c1 = tuxe.c1 and tuxg.c4 = tuxe.c3 and tuxg.c3 = tuxe.c2
 	   /*220721*/ and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8
   left join ( 
	   select tuxg.c1, tuxg.c3, /*tuxg.c4*/tuxe.c3 as factura, tkdm2.c8 as devprod, sum(tkdm2.c9) as cantdev 
		from keplersc.kdm1 tdm1 
			inner join keplersc.kdm2 tkdm2 on tdm1.c1 = tkdm2.c1 and tdm1.c6 = tkdm2.c6 
			/*220721*/ and tdm1.c2 = tkdm2.c2 and tdm1.c3 = tkdm2.c3 and tdm1.c4 = tkdm2.c4 and tdm1.c5 = tkdm2.c5
			/*220721*/ --inner join keplersc.kduxg tuxg on tdm1.c1 = tuxg.c1 /*and lpad(tdm1.c11,10,%1$L) = tuxg.c4*/ and tdm1.c10 = tuxg.c3
			inner join keplersc.kduxe tuxe 
			/*220721*/ -- on tuxg.c1 = tuxe.c1 and tuxg.c4 = tuxe.c9/*tuxe.c3*/ and tuxg.c3 = tuxe.c2 
			on tdm1.c1 = tuxe.c1 and tdm1.c6 = tuxe.c9 and tdm1.c10 = tuxe.c2 
			/*220721*/ and lpad(tdm1.c11,10,%1$L) = tuxe.c3 
			/*220721*/ and tdm1.c2 = tuxe.c5 and tdm1.c3 = tuxe.c6 and tdm1.c4 = tuxe.c7 and tdm1.c5 = tuxe.c8 
			inner join keplersc.kduxg tuxg on tuxg.c1 = tuxe.c1 and tuxg.c4 = tuxe.c9/*tuxe.c3*/ and tuxg.c3 = tuxe.c2 
		where /*tuxg.c2*/tuxe.c5 = %14$L and tuxe.c6 = %15$L and tuxe.c7 = %16$s and tuxe.c8 = %5$s  
		and tuxg.c1 = %6$L  
		/*220721*/ and lpad(/*tdm1.c11*/tuxe.c3,10,%1$L) = %8$L  
		group by tuxg.c1, tuxg.c3, /*tuxg.c4*/tuxe.c3, tkdm2.c8
	) tDev on tuxg.c1 = tDev.c1 and tuxg.c3 = tDev.c3 and tuxg.c4 = tDev.factura and tdm2.c8 = tDev.devprod 	
	left join (
		select Q1.sucursal, Q1.producto, coalesce(sum(Q1.cantent),0) - coalesce(sum(Q1.cantsal),0) existencias from 
			(select tinm.c1 as sucursal, tinm.c2 as producto, 
				case when (tinm.c5=%9$L and tinm.c6=%12$L) or (tinm.c5=%10$L and tinm.c6=%12$L) or (tinm.c5=%11$L and tinm.c6=%12$L) then sum(tinm.c11) end as cantent,
				case when (tinm.c5=%9$L and tinm.c6=%13$L) or (tinm.c5=%10$L and tinm.c6=%13$L) or (tinm.c5=%11$L and tinm.c6=%13$L) then sum(tinm.c11) end as cantsal 
	 		from keplersc.kdinm tinm
	 		where tinm.c1=%6$L
 	 		group by tinm.c1, tinm.c2, tinm.c5, tinm.c6, tinm.c11) as Q1
		Group by Q1.sucursal, Q1.producto
	) tInv on tuxg.c1 = tInv.sucursal and tdm2.c8 = tInv.producto
where tdm1.c1 = %6$L and tdm1.c10 = %7$L and lpad(tdm1.c11,10,%1$L) = %8$L 
	/*new 220721*/ and tdm1.c2 = %2$L and tdm1.c3 = %3$L and tdm1.c4 = %4$s and tdm1.c5 = 1
',cero,genero,naturaleza,grupo,tipo,sucursal_id,proveedor_id,referencia,genU,genX,genN,natA,natD,genDev,natDev,gpoDev);

raise notice '%', expSql;
select query_to_xml(expSql,false,true,'') into xmlDetalle;
--raise notice '%', xmlDetalle;

insert into tmpResultados(encabezado,detalle) values(xmlEncabezado,xmlDetalle);

return query select * from tmpResultados;

END;
$function$
