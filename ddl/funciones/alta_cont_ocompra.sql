CREATE OR REPLACE FUNCTION keplersc.alta_cont_ocompra(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de movimientos contables
--Autor: Luis Leal
--Fecha: 20/02/23
declare
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo numeric;
	tipo_clave numeric;
	fecha_operacion text; --yyyy-mm-dd
	referencia text;
	folio_poliza text;
	anio_en_curso text;
	mes_en_curso text;
	tipo_asiento_1 text;
	tipo_asiento_2 text;
	numero_partida_poliza_kdc int = 0;
	tipo_poliza_kdmm text = '';
	accion_poliza_kdc text = '';
	clave_compra text;
	desc_compra text;
	monto_compra text;
	ctd_gastos int;
	sql_gastos text;
	columna_prorrateo int;
	datos_gastos xml;
	cuenta_gasto text;
	prorrateo_gasto text;
	abono decimal = 0;
	cargo decimal = 0;
	total_monto decimal = 0;
	cuenta_cargo_abono text = '';
	nombre_cteprov text = '';

	--sumas
	monto_iva decimal = 0;		
	retencion_isr decimal  = 0;				
	retencion_iva decimal = 0;				
	otras_retenciones decimal = 0;	
	importe decimal = 0;	

	--cuentas contables
	cuenta_contable_iva text = '';
 	cuenta_contable_retencion_isr text = '';
 	cuenta_contable_retencion_iva text = '';
  	cuenta_contable_otras_retenciones text = '';

	--variables de uso general
	strValor text;
	strvarcont text;
	strMonto text;
	mensajeError text;
	varcont xml;
	expSql text='';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


begin

	sucursal_id := (xpath('//row/c1/text()', xmlkdm1))[1]; 
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; 
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1];
	fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; 
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; 
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;

	---montos--
	strMonto := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0.00')::text; 
	monto_iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0.00')::text; 
	retencion_isr := strMonto::decimal;	
	strMonto := coalesce((xpath('//row/c23/text()', xmlkdm1))[1]::text,'0.00')::text; 
	retencion_iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c49/text()', xmlkdm1))[1]::text,'0.00')::text; 
	otras_retenciones  := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0.00')::text; 
	importe := strMonto::decimal;

	--cuentas contables
 	cuenta_contable_iva := (xpath('//row/c21/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_isr := (xpath('//row/c22/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_iva := (xpath('//row/c64/text()', xmlKDMM))[1]::text;
  	cuenta_contable_otras_retenciones := (xpath('//row/c74/text()', xmlKDMM))[1]::text;

	--Obtener campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);

	folio_poliza := 'POLIZA' || tipo_poliza_kdmm  || anio_en_curso || mes_en_curso;


	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;
	accion_poliza_kdc := 'NUEVAPOLIZA';

	for clave_compra,desc_compra,monto_compra in select c8,c9,c11
	from keplersc.kdm6 where c1=sucursal_id and c2=genero 
	and c3=naturaleza and c4=grupo and c5=tipo_clave and c6=folio_operacion
	loop 
		
		select count(*) into ctd_gastos from keplersc.kdcatgastos where c1=clave_compra;
		if ctd_gastos > 0	then
		
			for i in 3..11 loop	
				
				if i = 3 or i = 5 or i = 7 or i = 9 or i = 11 then
							
					columna_prorrateo := i + 1;
					sql_gastos := format('select %1$s as cuenta,%2$s as prorrateo
					 from keplersc.kdcatgastos where c1=%3$L ',
					concat('c', i::text), concat('c', columna_prorrateo::text)  ,clave_compra);
					select query_to_xml(sql_gastos, false, true, '' ) :: xml into datos_gastos;
				
					cuenta_gasto := (xpath('//row/cuenta/text()', datos_gastos))[1];
					prorrateo_gasto := (xpath('//row/prorrateo/text()', datos_gastos))[1];
					cargo := monto_compra::numeric * (prorrateo_gasto::numeric/100);
					total_monto := total_monto + cargo;
								
					numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
         			-- CONT(T,W9,H(N1),"C",B8050,X9,W11,M18,"","","","","",W1...W6,B8095): B8095=""
					select xmlforest(fecha_operacion as fecha, cuenta_gasto as cuenta, 'C' as tipo_asiento, 
						cargo as monto,desc_compra as descrip, referencia as refer, 
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
					
				
				end if;
				
			end loop;
		
		end if;
			
	end loop;


	if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
	
		select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
		from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_cargo_abono := split_part(adicionales, '|', 1);	
		nombre_cteprov :=  split_part(adicionales, '|', 2);
		tipo_asiento_1 := 'C'; tipo_asiento_2 := 'A';
		
	else
	
		select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
		from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_cargo_abono := split_part(adicionales, '|', 1);
		nombre_cteprov :=  split_part(adicionales, '|', 2);
		tipo_asiento_1 := 'A'; tipo_asiento_2 := 'C';
	
	end if;

	--raise exception '%,%,%,%,%', total_monto, monto_iva, retencion_isr, retencion_iva,otras_retenciones;

	total_monto := total_monto + monto_iva - retencion_isr - retencion_iva - otras_retenciones; 

	numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;

	-- CONT(T,W9,B8000,B8090,B8051,B8020,W11,M18,"","","","","",W1...W6,B8095): B8095=""
	select xmlforest(fecha_operacion as fecha, cuenta_cargo_abono as cuenta, tipo_asiento_1 as tipo_asiento, 
		total_monto as monto,nombre_cteprov as descrip, referencia as refer, 
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


	if cuenta_contable_retencion_isr <> '' and retencion_isr <> 0.00 then 
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,M22,B8090,W15,W32,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_contable_retencion_isr as cuenta, tipo_asiento_1 as tipo_asiento, 
			retencion_isr as monto,nombre_cteprov as descrip, referencia as refer, 
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
		
	end if;


	if cuenta_contable_retencion_iva <> '' and retencion_iva <> 0.00 then 
		
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,M64,B8090,W23,W32,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_contable_retencion_iva as cuenta, tipo_asiento_1 as tipo_asiento, 
			retencion_iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
		
	end if;


	if cuenta_contable_otras_retenciones <> '' and otras_retenciones <> 0.00 then 
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,M74,B8090,W49,W32,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_contable_otras_retenciones as cuenta, tipo_asiento_1 as tipo_asiento, 
			otras_retenciones as monto,nombre_cteprov as descrip, referencia as refer, 
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
		
	end if;


	if cuenta_contable_iva <> '' and monto_iva <> 0.00 then 
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_contable_iva as cuenta, tipo_asiento_2 as tipo_asiento, 
			monto_iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
		
	end if;

	resultado := 1;
	mensaje := folio_poliza;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_ocompra() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
