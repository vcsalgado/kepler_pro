CREATE OR REPLACE FUNCTION keplersc.alta_cont_mov(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserción de movimientos contables
--Autor: Luis Leal
--Fecha: 19/10/22
declare
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo numeric;
	tipo_clave numeric;
	fecha_operacion text; --yyyy-mm-dd
	referencia text;
	folio_poliza text;
	anio_contable text ='';
	anio_en_curso text;
	mes_en_curso text;
	tipo_asiento_1 text;
	tipo_asiento_2 text;
	subtotal numeric = 0;
	iva numeric = 0;	
	monto numeric = 0;	
	cargo numeric = 0;
	abono numeric = 0;
 	factura_monto numeric  = 0;
 	factura_iva numeric  = 0;
	numero_partida_poliza_kdc numeric = 0;
	cuenta_contable_cargo text = '';
	cuenta_contable_abono text = '';
	cuenta_contable_iva text = '';
	campo_extra_cuenta_principal int;
	campo_extra_cuenta_secundaria int;
	cuenta_iva_complementario text = '';
	tipo_poliza_kdmm text = '';
	cuenta_cargo text = '';
	cuenta_abono text = '';
	nombre_cteprov text = '';
	accion_poliza_kdc text = '';
	cuenta_extra text = '';
	monto_extra text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	strvarcont text;
	strMonto text;
	mensajeError text;
	varcont xml;
	expSql text='';
	intValor int = 0;
	folio_id text = '';
	divide_cta_iva text = '';
	inventario text = '';

begin
	/*vcss se modifica el origen de los datos de dataxml a xmlkdm1, esto es por el
	 * proceso de regeneracion de polizas, el anio_contable no se utiliza
	--Trasaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1];
	anio_contable := (xpath('//document/ambiente/anio_contable/text()',dataxml))[1];

	--subtotal := (xpath('//document/k_subtotal/text()',dataxml))[1];
	iva := (xpath('//document/k_iva/text()',dataxml))[1];
	monto := (xpath('//document/k_monto/text()',dataxml))[1];	
*/
	sucursal_id := (xpath('//row/c1/text()', xmlkdm1))[1]; --(xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; --(xpath('//document/k_fecha/text()', dataxml))[1];	
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; --(xpath('//document/k_refer/text()',dataxml))[1];
	strMonto := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	monto := strMonto::decimal;

	
	--cuentas contables
 	cuenta_contable_cargo := (xpath('//row/c19/text()', xmlKDMM))[1]::text;
  	cuenta_contable_abono := (xpath('//row/c20/text()', xmlKDMM))[1]::text;
 	cuenta_contable_iva := (xpath('//row/c21/text()', xmlKDMM))[1]::text;
 
  	campo_extra_cuenta_principal := (xpath('//row/c25/text()', xmlKDMM))[1];
 	campo_extra_cuenta_secundaria := (xpath('//row/c26/text()', xmlKDMM))[1];
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;

	divide_cta_iva := coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,'');
 	/*raise exception '%,%,%,%,%' ,cuenta_contable_cargo, cuenta_contable_abono, cuenta_contable_iva,
 	campo_extra_cuenta_principal, campo_extra_cuenta_secundaria;*/
 
	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);

	folio_poliza := 'POLIZA' || tipo_poliza_kdmm  || anio_en_curso || mes_en_curso;

	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;

	accion_poliza_kdc := 'NUEVAPOLIZA';

	if substring(cuenta_contable_cargo,1,1) = 'V' or substring(cuenta_contable_abono,1,1) = 'V'
	or campo_extra_cuenta_principal < 0 or campo_extra_cuenta_secundaria < 0 then 
		
		for factura_monto,factura_iva,inventario in select c12,c13,c14 from keplersc.kdm5 where c1=sucursal_id and c2=genero 
		and c3=naturaleza and c4=grupo and c5=tipo_clave and c6=folio_operacion
		loop 
			select '<varcont><n5>25</n5><n6>19</n6><inventario>' || inventario || '</inventario></varcont>' into strvarcont;
			varcont := strvarcont ::xml;
			select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			cuenta_cargo := split_part(adicionales, '|', 1);	
			nombre_cteprov :=  split_part(adicionales, '|', 3); --Descripcion de la cuenta
		
			select '<varcont><n5>26</n5><n6>20</n6><inventario>' || inventario || '</inventario></varcont>' into strvarcont;
			varcont := strvarcont ::xml;
			select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			cuenta_abono := split_part(adicionales, '|', 1);
			cuenta_cargo:=cuenta_cargo;
			if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
				cargo := factura_monto;
				--if (xpath('//row/c30/text()', xmlKDMM))[1]::text  <> 'S' then
				if divide_cta_iva  <> 'S' then
					abono := factura_monto - factura_iva;
				else
					abono := factura_monto ;
				end if;
			else
				abono := factura_monto;
				--if (xpath('//row/c30/text()', xmlKDMM))[1]::text  <> 'S' then
				if divide_cta_iva  <> 'S' then
					cargo := factura_monto - factura_iva;
				else
					cargo := factura_monto ;
				end if;
			end if;
	
			--'LA CONTRAPARTIDA ES PARA CUANDO SE TIENE QUE CARGAR LO MISMO QUE SE ABONA
			if campo_extra_cuenta_principal < 0 or substring(cuenta_contable_cargo,1,1) = 'V' then 
				numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
				-- CONT(T,W9,B8000,"C",B8050,B8020,W11,M18,"","","","","",W1...W6,B8095)
				select xmlforest(fecha_operacion as fecha, cuenta_cargo as cuenta, 'C' as tipo_asiento, 
					cargo as monto,nombre_cteprov as descrip, referencia as refer, 
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
		
	
			if campo_extra_cuenta_secundaria < 0 or substring(cuenta_contable_abono ,1,1) = 'V' then 
				numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
				--CONT(T,W9,B8001,"A",B8051,B8020,W11,M18,"","","","","",W1...W6,B8095)
				select xmlforest(fecha_operacion as fecha, cuenta_abono as cuenta, 'A' as tipo_asiento, 
					abono as monto,nombre_cteprov as descrip, referencia as refer, 
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


	select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont;
	select * into resultado, mensaje, adicionales 
	from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
	cuenta_cargo := split_part(adicionales, '|', 1);	
	nombre_cteprov :=  split_part(adicionales, '|', 2);

	select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont;
	select * into resultado, mensaje, adicionales 
	from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
	cuenta_abono := split_part(adicionales, '|', 1);	

	if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
		tipo_asiento_1 := 'A'; tipo_asiento_2 := 'C';
		cargo := monto; abono := monto - iva;
		if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
			abono := monto ;
		end if;
	else
		tipo_asiento_1 := 'C'; tipo_asiento_2 := 'A';
		cargo := monto - iva ; abono := monto;
		--'LA CONTRAPARTIDA ES PARA CUANDO SE TIENE QUE CARGAR LO MISMO QUE SE ABONA
		if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
			cargo := monto ;
		end if;
	end if;

	if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
		cuenta_iva_complementario :=  (xpath('//row/c22/text()', xmlKDMM))[1]::text;
	end if;

	if campo_extra_cuenta_principal >= 0 and substring(cuenta_contable_cargo,1,1) <> 'V' then 		
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,B8000,"C",B8050,B8020,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_cargo as cuenta, 'C' as tipo_asiento, 
			cargo as monto,nombre_cteprov as descrip, referencia as refer, 
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

	if campo_extra_cuenta_secundaria >= 0 and substring(cuenta_contable_abono,1,1) <> 'V' then 
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,B8001,"A",B8051,B8020,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_abono as cuenta, 'A' as tipo_asiento, 
			abono as monto,nombre_cteprov as descrip, referencia as refer, 
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

	if iva <> 0 and cuenta_contable_iva <> '' then 	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		-- CONT(T,W9,B8002,B8090,B8052,B8020,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta_contable_iva as cuenta, tipo_asiento_1 as tipo_asiento, 
			iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
		if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' and cuenta_iva_complementario <> ''  then		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			-- CONT(T,W9,B8002,B8090,B8052,B8020,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_iva_complementario as cuenta, tipo_asiento_2 as tipo_asiento, 
				iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
	
	end if;

	--AFECTANDO LAS CUENTAS EXTRAS
	for i in 8..13 loop	
		
		strValor := format('<varcont><n5>%1$s</n5><n6>%2$s</n6></varcont>',50 + i, 28 + i );
		select strValor::xml into varcont;
	
		select * into resultado, mensaje, adicionales 
		from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);

		cuenta_extra := split_part(adicionales, '|', 1);	
		nombre_cteprov :=  split_part(adicionales, '|', 3); --Desripcion de la cuenta
	
		monto_extra :=  format('//document/k_monto_extra_%1$s/text()', (i-8)+ 1);
		monto_extra := (xpath(monto_extra,dataxml))[1];
			
		if cuenta_extra <> '' and monto_extra <> '0' and monto_extra <> '' then 
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			-- CONT(T,W9,B8000,"C",B8050,B8020,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_extra as cuenta, tipo_asiento_1 as tipo_asiento, 
				monto_extra as monto,nombre_cteprov as descrip, referencia as refer, 
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
	
	resultado := 1;
	mensaje := folio_poliza;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_mov() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
