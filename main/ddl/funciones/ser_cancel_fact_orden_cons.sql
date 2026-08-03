CREATE OR REPLACE FUNCTION keplersc.ser_cancel_fact_orden_cons(dataxml xml)
 RETURNS TABLE(encabezado xml)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Obtiene en formato XML el detalle de un folio a consultar de una orden facturada para cancelar
--Autor: Miriam Santana
--Fecha: 14/Dic/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;
	
	--Variables de uso general 
	strValor text = '||';
	espacio text = ' ';
	vacio text = '';
	srtcero text = '0';

	--xmlReqDoctos text = '';
	expSql text = '';

	--Variables de retorno
	xmlEncabezado xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()', dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1]; 
	folio := (xpath('//document/folio/text()', dataxml))[1]; 

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml
	);

	expSql= format('select dmm.c5 as k_tipon,dm1.c9 as k_fecha, dm1.c69 as k_hora, ''[''||mar.c1||''] ''||mar.c3 as k_tipo_orden, dm1.c122 as k_orden,
		dm1.c36 as k_natdocto,dm1.c37 as k_gpodocto,dm1.c38 as k_tipodocto,dm1.c39 as k_foliodocto, 
		dm1.c12 as k_vendedor, rec.c2 as k_nombre_recep, dm1.c11 as k_refer,dm1.c27 as k_pedimento,inf.c2 as k_claveinv,
		dm1.c10 as k_clave, dm1.c51 as k_montoext1,dm1.c52 as k_montoext2,dm1.c53 as k_montoext3,dm1.c54 as k_montoext4, 
		dm1.c32 as k_nombreprov, dm1.c33 as k_calleprov,dm1.c34 as k_coloniaprov,dm1.c35 as k_poblacionprov, dm1.c163 as k_cpprov,
		dm1.c22 as k_rfc,dm1.c99 as k_nombreimprfact,dm1.c14 as k_iva,dm1.c16-dm1.c14 as k_subtotal,dm1.c16 as k_monto,
		dm1.c165 as k_correo,dm1.c17 as k_plazo,dm1.c18 as k_vence,dm1.c30 as k_cond,''[''||fp.c1||''] ''||fp.c2 as k_f_pago,		
		''[''||cfd.c1||''] ''||cfd.c2 as k_cfdi,dm1.c161 as k_cuenta,dm1.c162 as k_m_pago,
		concat(regexp_replace(dm1.c24,''\r|\n'','' '', ''g''),'' '',dm1.c25,'' '',dm1.c26) as k_coment,dmm.c16 as k_porciva 
		from keplersc.kdm1 dm1
		inner join keplersc.kdmm dmm on dmm.col_sucursal=dm1.c1 and	dmm.c1=dm1.c2 and dmm.c2=dm1.c3 and dmm.c3=dm1.c4 and dmm.c4=dm1.c5
		left join keplersc.kdmargen mar on mar.c1=dm1.c121
		left join keplersc.kdinf inf on inf.c2=dm1.c100 
		left join keplersc.kdrecep rec on rec.c1=dm1.c12
		left join keplersc.kdf3uso cfd on cfd.c1=dm1.c164
		left join keplersc.kdf3fp fp on fp.c1=dm1.c160
		where dm1.c1=%1$L and dm1.c2=%2$L and dm1.c3=%3$L and dm1.c4=%4$s and dm1.c5=%5$s and dm1.c6=%6$L'
		,sucursal_id,genero,naturaleza,grupo,tipo,folio);	

select query_to_xml(expSql,false,true,'') into xmlEncabezado;

insert into tmpResultados(encabezado) 
	values(xmlEncabezado);

return query select * from tmpResultados;

END;
$function$
