CREATE OR REPLACE FUNCTION keplersc.autos_com_nvo_sel(dataxml xml)
 RETURNS xml
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: 
--Obtiene en formato XML el encabezado de una sola compra
--Autor: Equipo desarrollo JM 
--Fecha: 10/Oct/22
--Bitacora de cambios

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	folio text;
	status text;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';
	espacio text = ' ';
	cero text = '0';

	--Variables de retorno
	xmlEncabezado xml;

begin	
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	genero := (xpath('//document/genero/text()', dataxml))[1];
	naturaleza := (xpath('//document/naturaleza/text()', dataxml))[1];
	grupo := (xpath('//document/grupo/text()', dataxml))[1];
	tipo := (xpath('//document/tipo/text()', dataxml))[1];
	folio := (xpath('//document/folio/text()', dataxml))[1];

	-- Added : 20221024 
	status := '';
	if xpath_exists('//document/estatus/text()', dataxml) = true /*false*/ then 
		status := (xpath('//document/estatus/text()', dataxml))[1];
	end if;

	drop table if exists tmpResultados;
	create temp table tmpResultados (
		encabezado xml 
	);

	-- ENCABEZADO ... 
	if length(status) > 0 then
	
		--expSql = format(
		expSql = '
		select tdm1.c9 as k_fecha, tdm1.c100 as k_claveinv, tdm1.c108 as k_tipopagos, tdm1.c11 as k_refer  
		, tdm1.c10 as k_clave, tdm1.c89 as k_importe, tdm1.c14 as k_iva, tdm1.c16 as k_monto, tdm1.c54 as k_montoext4  
		, tdm1.c17 as k_plazo, tdm1.c18 as k_vence, tdm1.c30 as k_cond, tdm1.c22 k_rfc, tdm1.c163 k_cp  
		, tdm1.c24 as k_coment, tdm1.c25 as k_coment2, tdm1.c26 as k_coment3
		, tdm1.c138 as k_kilometraje
		, tdm1.c12 as k_vendedor, tdm1.c44 as k_proyecto, tdm1.c45 as k_subctabanco 
		'
		;
		
		if naturaleza = 'D' then 
			expSql = expSql || ', tdm1.c39 k_folio_ref ';
		else 
			expSql = expSql || ' '; 
		end if;
		 
		expSql = format(expSql || 
		'from keplersc.kdm1 as tdm1 
		inner join keplersc.kdinf as inf on inf.c1 = tdm1.c1 and inf.c2 = tdm1.c100 
		where tdm1.c2 = %2$L and tdm1.c3 = %3$L and tdm1.c4 = %4$s and tdm1.c5 =  %5$s and tdm1.c6 = %6$L and tdm1.c1 = %1$L 
			and inf.c31 = %7$s 
		'
		,sucursal_id,genero,naturaleza,grupo,tipo,folio,status,espacio,cero);	
	
		--raise notice '%', expSql;
		
	else
	
		expSql = format(
		'
		select tdm1.c9 as k_fecha, tdm1.c100 as k_claveinv, tdm1.c108 as k_tipopagos, tdm1.c11 as k_refer  
		, tdm1.c10 as k_clave, tdm1.c89 as k_importe, tdm1.c14 as k_iva, tdm1.c16 as k_monto, tdm1.c54 as k_montoext4  
		, tdm1.c17 as k_plazo, tdm1.c18 as k_vence, tdm1.c30 as k_cond, tdm1.c22 k_rfc, tdm1.c163 k_cp  
		, tdm1.c24 as k_coment, tdm1.c25 as k_coment2, tdm1.c26 as k_coment3, tdm1.c39 k_folio_ref 
		, tdm1.c138 as k_kilometraje 
		, tdm1.c12 as k_vendedor, tdm1.c44 as k_proyecto, tdm1.c45 as k_subctabanco 
		from keplersc.kdm1 as tdm1  
		where tdm1.c2 = %2$L and tdm1.c3 = %3$L and tdm1.c4 = %4$s and tdm1.c5 =  %5$s and tdm1.c6 = %6$L and tdm1.c1 = %1$L 
		'
		,sucursal_id,genero,naturaleza,grupo,tipo,folio,espacio,cero);
	
	end if;

	--raise notice '%', expSql;
	select query_to_xml(expSql,false,true,'') into xmlEncabezado;
	--raise notice '%', xmlEncabezado;
	
	--insert into tmpResultados(encabezado/*,detalle*/) values(xmlEncabezado/*,xmlDetalle*/);
	--return query select * from tmpResultados;

	return xmlEncabezado;

END;
$function$
