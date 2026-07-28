CREATE OR REPLACE FUNCTION keplersc.alta_cont_transfer_rollback(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos contables ... Gastos ( Compras )
--             Opcion Exclusiva para los Transfers Rollbacks 
--Autor: Jose Mendoza 
--Fecha: 2024-04-19
---- Adapted Transfer Operations 

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

	-- Added by JMM 20240304 
	rec record;
	xmlkdm1_partida xml;
	rec1 record;
	free_text text = '';

	-- Added by JMM 20240313
	flag_gastos text = '';

	--Added by JMM 20240419
	totalReg int = 0;
	hora_movto text = '';

begin

	sucursal_id := (xpath('//row/c1/text()', xmlkdm1))[1]; --(xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r4/text()', dataxml))[1];

	-- Commented by JMM 20240419
	--fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; --(xpath('//document/k_fecha/text()', dataxml))[1];
		
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; --(xpath('//document/k_refer/text()',dataxml))[1];
	strMonto := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	monto := strMonto::decimal;


	-- Added by JMM 20240419 
	fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
	hora_movto := coalesce((xpath('//document/movimiento/hora/text()',dataxml))[1]::text,'')::text; 
	--hora_movto := coalesce((xpath('//document/k_hora/text()', dataxml))[1]::text,'')::text;
	hora_movto := substring(hora_movto from 1 for 8/*5*/);
	-- Added by JMM 20240419
	if /*length(usuario_movto) = 0 or*/ length(hora_movto) = 0 or length(fecha_operacion) = 0 or left(trim(fecha_operacion),4) = '1800' then 
		raise exception '%', 'Los Datos de la Operacion No estan Completos [Fecha, Hora] ...';
	end if;
	
	
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


	-- Added by JMM 20240313 ... Validation that limit this function to specific tags (new expenses schema)
	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	else
		raise exception '%', 'No se pudo Validar el Esquema para utilizar la Funcion Contable de Transfer Rollback ...';
	end if;
	-- UPD Condition by JMM 20240419 
	if upper(flag_gastos) <> 'CXP_TRANSFER_CONVERT' then
		raise exception '%', 'Esquema No Permitido para utilizar la Funcion Contable de Transfer Rollback ...';
	end if;


	-- Added by JMM 20240419 
	-- Validar Existencia de Datos a Procesar en KDM5 (sera la base para las TRNs de CxP & CT)
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave 
		and c6 = folio_operacion and st_x_comprobar = 'X' and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto;
	if totalReg = 0 then
		mensaje := 'No se encontraron Registros a Procesar en kdm5 ... CT Transfer Rollback';
		raise exception '%', mensaje;
	end if;


	folio_poliza := 'POLIZA' || tipo_poliza_kdmm  || anio_en_curso || mes_en_curso;

	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;

	accion_poliza_kdc := 'NUEVAPOLIZA';

	--Added by JMM 20240305 
	free_text := '';

	-- Commented by JMM 20240304, This code not apply for these options  ( To Check )
	-- if it will apply later, it must to be analyzed and customized 
	-- Code for this function is based on kdm5 in order to create policy items 

	/*
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
	*/

	for /*factura_monto,factura_iva,inventario*/ rec in 
		select /*c12,c13,c14*/ * from keplersc.kdm5 
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave  
			and c6 = folio_operacion and st_x_comprobar = 'X' and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
			and hora_comprobacion = hora_movto 
	loop

		select w.* into rec1 from keplersc.kduxg g 
		inner join keplersc.kduxe e on g.c1 = e.c1 and g.c2 = e.c5 and g.c3 = e.c2 and g.c4 = e.c3
		inner join keplersc.kdm1 w on w.c1 = e.c1 and w.c2 = e.c5 and w.c3 = e.c6 and w.c4 = e.c7 and w.c5 = e.c8 and w.c6 = e.c9 
		where e.c6 = 'A' and g.c2 = rec.c2/*'X'*/ and (g.c4 = rec.c14 or g.doc_refer_compl = rec.c14) and g.c3 = rec.cve_prov_oper 
			and g.cve_prov_pago = case when length(coalesce(g.cve_prov_pago,'')) = 0 then g.cve_prov_pago else rec.cve_prov_pago end 
			and g.c1 = rec.c1 /*Added by JMM 20240805*/;
		
		if not found then 
			mensaje := 'No se encontro registro en KDM1 de la CxP de Origen {KDM5} ... ' || rec.c14;
			raise exception '%',mensaje;
		else
			mensaje := '';
			-- For Testing, It Continuing ...
			/*
			raise exception '%''%''%''%''%''%''%''%''%'
				,rec1.c1,rec1.c2,rec1.c3,rec1.c4,rec1.c5,rec1.c6,rec1.c9,rec1.c10,rec1.c11;
			*/
		end if;
		
		--Obtener xml de KDM1 contenido en la partida(s) del documento (de pago) generado 		
		expSql = 'select * from keplersc.kdm1 where' || 
			' c1=' || E'\'' || rec1.c1 || E'\'' ||  
			' and c2=' || E'\'' || rec1.c2 || E'\'' ||
			' and c3=' || E'\'' || rec1.c3 || E'\'' || 
			' and c4=' || rec1.c4 || 
			' and c5=' || rec1.c5 ||
			' and c6=' || E'\'' || rec1.c6 || E'\'';

		select query_to_xml(expSql, true, false, '') into xmlkdm1_partida;
	
	
		-- Init Numeric Vars
		monto := 0; 
		iva := 0;
	
		-- Getting Values ( Se manejaran por partida.DOC en kdm5 )
		monto := rec.c12;
		iva := rec.c13;
		
		
		select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
		from keplersc.cont_format_account_smov(
			/*xmlKDM1*/xmlkdm1_partida, 
			xmlKDMM,
			folio_operacion/*rec.c6*/,
			varcont
		);	
		-- Es un contramovimiento, el Cargo de Origen sera Abono ... JMM 20240419
		cuenta_abono /*cuenta_cargo*/ := split_part(adicionales, '|', 1);	
		nombre_cteprov :=  split_part(adicionales, '|', 2);
	
		select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
		from keplersc.cont_format_account_smov(
			/*xmlKDM1*/xmlkdm1_partida, 
			xmlKDMM,
			folio_operacion/*rec.c6*/,
			varcont
		);	
		-- Es un contramovimiento, el Abono de Origen sera Cargo ... JMM 20240419
		cuenta_cargo /*cuenta_abono*/ := split_part(adicionales, '|', 1);	
	
	
		/*raise exception '%''%''%''%''%''%','Datos_Cargo',cuenta_cargo,nombre_cteprov,folio_operacion,' - ',rec.c6;*/
		/*free_text := free_text || ', ' || cuenta_abono /*cuenta_cargo*/;*/
	
	
		if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
			-- Es un contramovimiento, el Cargo de Origen sera Abono ... JMM 20240419
			tipo_asiento_1 := 'C' /*'A'*/; tipo_asiento_2 := 'A' /*'C'*/;
			cargo := monto; abono := monto - iva;
			if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
				abono := monto ;
			end if;
		else
			-- Es un contramovimiento, el Cargo de Origen sera Abono ... JMM 20240419
			tipo_asiento_1 := 'A' /*'C'*/; tipo_asiento_2 := 'C' /*'A'*/;
			cargo := monto - iva ; abono := monto;
			--'LA CONTRAPARTIDA ES PARA CUANDO SE TIENE QUE CARGAR LO MISMO QUE SE ABONA
			if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
				cargo := monto ;
			end if;
		end if;
	
		if (xpath('//row/c30/text()', xmlKDMM))[1]::text  = 'S' then
			cuenta_iva_complementario :=  (xpath('//row/c22/text()', xmlKDMM))[1]::text;
		end if;
	
		free_text := free_text || ', ' || tipo_asiento_2  || ' : ' || cuenta_iva_complementario;
	
	
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
	
		-- Commented by JMM 20240304 ... Not Apply for these operations ( To Check )
		/*
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
		*/
	
	end loop; -- For..Loop records kdm5 

	-- For Testing ...
	/*raise exception '%',free_text;*/
	
	
	-- START SECTION : Creating New Policie for Tranfers ... Added by JMM 20240806  
	
	--if upper(flag_gastos) = 'CXP_TRANSFER' then
	
		select xmlforest(sucursal_id as sucursal, anio_en_curso as anio, mes_en_curso as mes, 
				folio_poliza as num_poliza, tipo_poliza_kdmm as tipo)::text into strValor;	
			
		select '<document>'||strValor||'</document>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_agrupa_cuentas(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;	
					
	--end if; 

	-- END SECTION : Creating New Policie for Tranfers ... Added by JMM 20240806

	
	resultado := 1;
	mensaje := folio_poliza;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_transfer_rollback() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
