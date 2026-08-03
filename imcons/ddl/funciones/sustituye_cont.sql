CREATE OR REPLACE FUNCTION keplersc.sustituye_cont(dataxml xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza sustitucion de cobro
--Autor: Luis Leal
--Fecha: 19/12/22
--Bitacora de cambios
--30/10/2024 Miriam Santana: Se incluye validaciones para anulacion de cobros, antes sustitucion
declare
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo numeric;
	tipo_clave numeric;
	fecha_operacion text; --yyyy-mm-dd
	nombre_cteprov text;
	referencia text;
	anio_contable text ='';
	anio_en_curso text;
	mes_en_curso text;
	folio_poliza text;
	tipo_poliza_kdmm text;
	accion_poliza_kdc text;
	tabla_polizas text;

	--SUSTITUCION
	folio_a_sustituir text;
	genero_a_sustituir text;
	naturaleza_a_sustituir text;
	grupo_a_sustituir text;
	tipo_a_sustituir text;
	fecha_doc_a_sustituir text;
	anio_doc_a_sust text;
	mes_doc_a_sust text;
	tipo_poliza text;

	--variables loop
	clave_cuenta text;
	descr_poliza text;
	tipo_asiento_kdc text;
	monto text;
	numero_partida_poliza_kdc numeric = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	strMonto text;
	mensajeError text;
	varcont xml;
	expSql text='';
	intValor int = 0;
	folio_id text = '';


begin
	--Transaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];


	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;
	folio_poliza := 'POLIZA' || tipo_poliza_kdmm || anio_en_curso || mes_en_curso ;
	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;
	accion_poliza_kdc := 'NUEVAPOLIZA';

	--SUSTITUCION
	naturaleza_a_sustituir := (xpath('//document/k_natdocto/text()', dataxml))[1];
	grupo_a_sustituir := (xpath('//document/k_gpodocto/text()', dataxml))[1];
	tipo_a_sustituir := (xpath('//document/k_tipodocto/text()', dataxml))[1];
	folio_a_sustituir := (xpath('//document/k_foliodocto/text()', dataxml))[1];

	select c9 into fecha_doc_a_sustituir from keplersc.kdm1 where c1=sucursal_id and c2=genero and c3=naturaleza_a_sustituir 
	and c4=grupo_a_sustituir::numeric and c5=tipo_a_sustituir::numeric and c6=folio_a_sustituir;	
	
	anio_doc_a_sust := substring(fecha_doc_a_sustituir,3,2);
	mes_doc_a_sust := substring(fecha_doc_a_sustituir,6,2);

	tabla_polizas := 'keplersc.kdc2' || anio_doc_a_sust || mes_doc_a_sust;

	expSql := format('select c3,c4,c5,c6,c7 from %1$s 
	where c14=%2$L and c15=%3$L and c16=%4$L and c17=%5$s  and c18=%6$s  and c19=%7$L ',
	tabla_polizas, sucursal_id,genero, naturaleza_a_sustituir, grupo_a_sustituir, tipo_a_sustituir, folio_a_sustituir);

	for clave_cuenta,tipo_asiento_kdc,monto, descr_poliza, referencia in execute expSql
	loop 
		
		if tipo_asiento_kdc = 'C' then
			tipo_asiento_kdc := 'A';
		else
			tipo_asiento_kdc := 'C';
		end if;
		
		--MSS 30102024 Es la misma descripcion de la poliza original
		--descr_poliza := concat('SUST: ', sucursal_id, '-' ,genero, naturaleza_a_sustituir, '000' ,  grupo_a_sustituir, '000', tipo_a_sustituir, '-', folio_a_sustituir, ' ',descr_poliza );

		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--CONT(T,W9,X8,X10,X11,X9,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_kdc as tipo_asiento, 
			monto,descr_poliza as descrip, referencia as refer, 
			tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
			sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza, folio_poliza,
			numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	
	end loop;

	resultado := 1;
	mensaje := folio_poliza::text;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'sustituye_cont() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
