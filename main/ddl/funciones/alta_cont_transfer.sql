CREATE OR REPLACE FUNCTION keplersc.alta_cont_transfer(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza insercion de movimientos contables de transferencia y cheque
--Autor: Victor Salgado
--Fecha: 12/11/2025
--Bitacora de cambios


declare
	--Variables para xml 
	suc_id text;
	genero text;
	naturaleza text;
	grupo numeric;
	tipo_clave numeric;
	fecha_operacion text; --yyyy-mm-dd
	nombre_cteprov text;
	referencia text;
	anio_en_curso text;
	mes_en_curso text;
	folio_poliza text;
	tipo_poliza_kdmm text;
	accion_poliza_kdc text;
	tipo_asiento_1 text;
	tipo_asiento_2 text;
	afecta_costo_inventario text;
	cargo_abono_al_costo text;
	costo numeric;
	
	--sumas
	str_monto_iva text;		
	str_monto_total text;
	str_retencion_iva text;				
	str_otras_retenciones text;	
	str_monto_ieps_o_retencion_isr text;

	--cuentas contables
	cuenta_contable_iva text = '';
  	cuenta_contable_ieps text = '';
 	cuenta_contable_retencion_isr text = '';
 	cuenta_monto_ieps_o_retencion_isr text = '';
 	cuenta_contable_retencion_iva text = '';
  	cuenta_contable_otras_retenciones text = '';

	--variables loop
  	partida numeric;
	clave_cuenta text;
	descr_cuenta text;
	tipo_asiento_kdc text;
	monto text;
	inventario text;
	numero_partida_poliza_kdc numeric = 0;
	--Added by JMM 20240308
	afectacion text = '';
	--Added by JMM 20240717
	concept_prspto text = '';

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

	--Added by JMM 20240308
	flag_contrarec text = '';
	afecta_inventario text = '';

	--Added by JMM 20240717
	var_concept_prspto text = '';

	--Added by JMM 20241015 
	cuenta_prov_int text;
	cuenta_prov_int_dscr text;
	prov_int text;
	clave_gpogasto text;
	--Added by JMM 20241016  
	recp record;
	cuenta_iva_param text;
	
begin
	--Trasaccion
	suc_id := (xpath('//row/c1/text()', xmlkdm1))[1]; 
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; 
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1];
	fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; 
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; 

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

	for partida,clave_cuenta,descr_cuenta,tipo_asiento_kdc,monto,inventario ,afectacion,concept_prspto
		in select c7,c8,c9,c10,c11,c13 ,c12,ctopto
		from keplersc.kdm6 
		where c1 = suc_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion
	loop 
		flag_contrarec = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;
		
		var_concept_prspto := '';
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		--CONT(T,W9,X8,X10,X11,X9,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_kdc as tipo_asiento, 
			monto,descr_cuenta as descrip, referencia as refer, 
			tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
			suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza, folio_poliza,
			numero_partida_poliza_kdc as numero_partida
			, var_concept_prspto as var_concept_prspto)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;

	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_transfer() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
