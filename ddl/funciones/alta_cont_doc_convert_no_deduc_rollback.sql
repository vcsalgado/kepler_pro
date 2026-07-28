CREATE OR REPLACE FUNCTION keplersc.alta_cont_doc_convert_no_deduc_rollback(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos contables
--Autor: Jose Mendoza 
--Fecha: 2024-09-27
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
	-- Commented by JMM 20240404
	/*
	str_monto_iva text;		
	str_monto_total text;
	*/
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
	--Added by JMM 20240723
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

	--Added by JMM 20240404 
	proveedor text = '';
	subtotal numeric = 0;
	iva_factor numeric = 0;
	str_monto_iva numeric = 0;		
	str_monto_total numeric = 0;
	cuenta_abono_param text = '';
	cuenta_iva_param text = '';
	cuenta_dscr text = '';
	iva_acreditado numeric = 0;
	pagos numeric = 0;
	anio text = '';
	var_st_compr text = '';
	recg record;
	recp record;

	--Added by JMM 20240514
	totalReg numeric = 0;
	asiento_reversed text = '';

	--Added by JMM 20240723
	var_concept_prspto text = '';
	refanterior text = '';

	--Added by JMM 20240926
	partidas_new numeric;
	partidas_bef numeric;
	cuenta_destino text = '';

begin
	--Trasaccion
	sucursal_id := (xpath('//row/c1/text()', xmlkdm1))[1]; 
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; 
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1];
	fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; 
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; 
	--sumas
	-- Commented by JMM 20240404
	/*
	str_monto_iva := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0')::text; 	
	str_monto_ieps_o_retencion_isr := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0')::text; 	
	str_retencion_iva:= coalesce((xpath('//row/c23/text()', xmlkdm1))[1]::text,'0')::text; 		
	str_otras_retenciones := coalesce((xpath('//row/c49/text()', xmlkdm1))[1]::text,'0')::text; 		
	str_monto_total := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0')::text; 
	*/
	--cuentas contables
 	cuenta_contable_iva := (xpath('//row/c21/text()', xmlKDMM))[1]::text;
 	-- Commented by JMM 20240404
 	/*
  	cuenta_contable_ieps := (xpath('//row/c23/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_isr := (xpath('//row/c22/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_iva := (xpath('//row/c64/text()', xmlKDMM))[1]::text;
  	cuenta_contable_otras_retenciones := (xpath('//row/c74/text()', xmlKDMM))[1]::text;
  	*/
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;
	afecta_costo_inventario := (xpath('//row/c77/text()', xmlKDMM))[1]::text;
	cargo_abono_al_costo := (xpath('//row/c67/text()', xmlKDMM))[1]::text;


	--Added by JMM 20240723 
	refanterior := coalesce((xpath('//document/k_docto/text()',dataxml))[1],'');


	--Added by JMM 20240308 ... Moved here by JMM 20240404

	var_st_compr = '';

	flag_contrarec = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_contrarec) <> 'CXP_CONTR_REC_CONVERT_NO_DEDUC_ROLLBACK' then 
		raise exception '%', 'Se esta llamando a la funcion [ alta_cont_doc_convert_no_deduc_rollback ] desde una Operacion No Valida ...';
	else
		var_st_compr = 'X';
	end if;


	-- VARs Added by JMM 20240404

	proveedor := coalesce((xpath('//document/k_clave_oper/text()',dataxml))[1],'');

	if length(proveedor) = 0 then
		mensajeError := 'No se pudo obtener el Proveedor del Documento a Comprobar ...';
		raise exception '%',mensajeError;
	end if;

	-- Adapted by JMM 20240514 
	/*fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;*/
	fecha_operacion := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;


	strMonto := coalesce((xpath('//document/k_iva/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	str_monto_iva := strMonto::decimal;
	strMonto := coalesce((xpath('//document/c_monto/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	str_monto_total := strMonto::decimal;

	subtotal := str_monto_total - str_monto_iva;

	if str_monto_total <= 0 then
		mensajeError := 'El Monto de la Operacion No puede ser menor o igual a cero ...';
		raise exception '%',mensajeError;
	end if;

	iva_factor := (str_monto_iva * 100) / subtotal;
	iva_factor := round(iva_factor,2);

	iva_acreditado := 0;
	pagos := 0;

	-- N.A. para este Tipo de Documento
	/* -- START : Commented Segment	
	 
	if str_monto_iva > 0 then 
	
		select w.* into recg from keplersc.kduxg w 
		where w.c1 = sucursal_id and w.c2 = genero and w.c3 = proveedor and c4 = referencia and upper(st_x_comprobar) = 'X'
			/*Added by JMM 20240723*/ and doc_refer_compl = refanterior;
		if not found then 
			mensajeError := 'No se encontro Registro en KDUXG de la CxP Comprobada a Revertir ... ';
			raise exception '%', mensajeError;
		else
		
			pagos := recg.c6;
			if recg.c8 > 0 then
				iva_acreditado := recg.c8;
			end if;
		
			/*raise exception '%FACTORIVA ''%IVACRED ''%PAGOS ''%IVACALC ', iva_factor, iva_acreditado, pagos, round( (recg.c6 * iva_factor) / (100 + iva_factor) , 2);*/
		
			-- Adapted by JMM 20240515
			if pagos > 0 and abs( iva_acreditado /*<>*/ - round( (recg.c6 * iva_factor) / (100 + iva_factor) , 2) ) > 0.10 then
				mensajeError := 'Discrepancia en la Conversion de IVA en KDUXG de la CxP Comprobada a Revertir... ';
				raise exception '%', mensajeError;
			end if;
		
		end if;
	
	end if;
	
	*/ -- END : Commented Segment

	cuenta_abono_param := '';
	cuenta_iva_param := '';

	anio := extract(year from to_date(fecha_operacion,'YYYY-MM-DD'))::text;
	anio := right(anio,2);

	-- CTA GASTOS X COMPROBAR  ... Cuenta Gastos x Comprobar

	-- Segment Adapted by JMM 20240926 
	/*
	select p.* into recp from keplersc.param_oper p 
	where p.sucursal = sucursal_id and upper(p.parametro) = upper(trim('Cuenta Gastos x Comprobar'));
	if not found then 
		mensajeError := 'No se encontro el Parametro de la Cuenta Gastos x Comprobar en la Tabla PARAM_OPER ... ';
		raise exception '%', mensajeError;
	else
		cuenta_abono_param := recp.valor;
	end if;

	if length(trim(cuenta_abono_param)) = 0 then
		mensajeError := 'El Parametro de la Cuenta Gastos x Comprobar en PARAM_OPER No esta Registrado ... ';
		raise exception '%', mensajeError;
	end if;
	*/

	--Added by JMM 20240926 
	partidas_bef := 0;
	select count(*) into partidas_bef from keplersc.kdm6  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion;
	if partidas_bef <> 1 then
		mensajeError := 'El Documento Origen [Kdm6] No es elegible para Revertirse como No Deducible ...';
		raise exception '%',mensajeError;
	else
		select * into recp from keplersc.kdm6  
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion;
		if not found then 
			mensajeError := 'El Documento Origen [Kdm6] a Revertirse, No fue encontrado en la BD ... ';
			raise exception '%', mensajeError;
		else
			if upper(recp.c10) <> upper('C') then
				mensajeError := 'El Tipo de Movimiento del Documento Origen [Kdm6] No es Valido ... ';
				raise exception '%', mensajeError;
			else
				cuenta_abono_param := recp.c8;
			end if;
		end if;
	end if;

	select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(cuenta_abono_param, anio);
	if resultado = '0' then
		raise exception '%', mensaje;
	end if;

	-- Verify DOC to be Reversed (Deleted)
	partidas_bef := 0;
	cuenta_destino := '';
	select count(*) into partidas_bef from keplersc.kdmdocsnodeduc  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion;
	if partidas_bef <> 1 then
		mensajeError := 'El Documento Destino [kdmdocsnodeduc] No es elegible para Revertirse como No Deducible ...';
		raise exception '%',mensajeError;
	else
		select * into recg from keplersc.kdmdocsnodeduc  
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion;
		if not found then 
			mensajeError := 'El Documento Destino [kdmdocsnodeduc] a Revertirse, No fue encontrado en la BD ... ';
			raise exception '%', mensajeError;
		else
			if upper(recg.c10) <> upper('C') then
				mensajeError := 'El Tipo de Movimiento del Documento Destino [kdmdocsnodeduc] No es Valido ... ';
				raise exception '%', mensajeError;
			else
				cuenta_destino := recg.c8;
			end if;
		end if;
	end if;

	select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(cuenta_destino, anio);
	if resultado = '0' then
		raise exception '%', mensaje;
	end if;


	-- N.A. para este Tipo de Documento
	/* -- START : Commented Segment

	if iva_acreditado > 0 then
	
		-- CTA IVA ACREDITABLE ... Cuenta Gastos Iva Acreditable
		select p.* into recp from keplersc.param_oper p 
		where p.sucursal = sucursal_id and upper(p.parametro) = upper(trim('Cuenta Gastos Iva Acreditable'));
		if not found then 
			mensajeError := 'No se encontro el Parametro de la Cta Gastos Iva Acreditable en la Tabla PARAM_OPER ... ';
			raise exception '%', mensajeError;
		else
			cuenta_iva_param := recp.valor;
		end if;
	
		if length(trim(cuenta_iva_param)) = 0 then
			mensajeError := 'El Parametro de la Cuenta Gastos Iva Acreditable en PARAM_OPER No esta Registrado ... ';
			raise exception '%', mensajeError;
		end if;
	
		select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(cuenta_iva_param, anio);
		if resultado = '0' then
			raise exception '%', mensaje;
		end if;
	
	end if;

	*/ -- END : Commented Segment

	-- END : VARs Added by JMM 20240404


	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);

	folio_poliza := 'POLIZA' || tipo_poliza_kdmm || anio_en_curso || mes_en_curso ;

	/*
	raise exception '%', ' '
		|| ' | ' || ' ' || ' | ' || 'Fecha Operacion : ' || fecha_operacion 
		|| ' | ' || ' ' || ' | ' || 'Anio_en_curso : ' || anio_en_curso 
		|| ' | ' || ' ' || ' | ' || 'Mes_en_curso : ' || mes_en_curso ;
	*/

	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;

	accion_poliza_kdc := 'NUEVAPOLIZA';

	if (xpath('//row/c6/text()', xmlKDMM))[1]::text  = 'S' and (xpath('//row/c71/text()', xmlKDMM))[1]::text  = 'S' then 
	
		--Added by JMM 20240926
		partidas_new := 0; 
	
		for partida,clave_cuenta,descr_cuenta,tipo_asiento_kdc,monto,inventario ,afectacion/*Added by JMM 20240308*/ 
			,concept_prspto /*Added by JMM 20240718*/ 
			in select c7,c8,c9,c10,c11,c13 ,c12/*Added by JMM 20240308*/ ,ctopto/*Added by JMM 20240723*/ from keplersc.kdmdocsnodeduc 
			where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion
		loop 
			
			--Added by JMM 20240926
			partidas_new := partidas_new + 1; 
		
			-- This DOC must have 1 row with value = C 
			if tipo_asiento_kdc <> 'C' then
				mensajeError := 'El Tipo de Movimiento del Documento Destino [kdmdocsnodeduc] No es Valido ... ';
				raise exception '%', mensajeError;		
			end if;

			-- Code Added by JMM 20240514 to get value for : asiento_reversed
			asiento_reversed := '';
			if tipo_asiento_kdc = 'A' then asiento_reversed := 'C'; end if;
			if tipo_asiento_kdc = 'C' then asiento_reversed := 'A';	end if;
			if length(asiento_reversed) = 0 then
				mensaje := 'No se pudo obtener el Tipo de Asiento para el Registro en la Poliza  ...  partida ' || partida::text;
				raise exception '%' , mensaje;
			end if;
			
			--Added by JMM 20240723 
			var_concept_prspto := coalesce(concept_prspto,'');
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--CONT(T,W9,X8,X10,X11,X9,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, asiento_reversed /*tipo_asiento_kdc*/ as tipo_asiento, 
				monto,descr_cuenta as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida 
				, var_st_compr as var_st_compr /*Added by JMM 20240407*/
				, var_concept_prspto as var_concept_prspto /*Added by JMM 20240723*/)::text into strValor;
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
		
			--Moved here by JMM 20240308, para que aplique para ambas opciones
			if tipo_asiento_kdc = 'A' then
				costo := -(monto::numeric);
			else
				costo := monto::numeric;
			end if;
		
		
			/*if upper(flag_contrarec) = 'CXP_CONTR_REC' then*/  -- Moved and evaluated to UP 20240404
			
		
				-- N.A. para este Tipo de Documento
				/* -- START : Commented Segment
			
				afecta_inventario = '';
				if length(trim(inventario)) > 0 then
				
					afecta_inventario := afectacion;
					if length(trim(afecta_inventario)) = 0 then
						mensaje := 'No se cuenta con la afectacion para el inventario registrado ' || inventario || ' , partida ' || partida::text;
						raise exception '%' , mensaje;
					end if;
				
					-- For Testing ...
					--raise exception '%''%''%''%''%',inventario,' - ',afecta_inventario,' - ',partida;
				
					/*
					insert into keplersc.kdsunicosto (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11 , st_x_comprobar/*Added by JMM 20240405*/) 
					values(sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,sucursal_id, inventario, afecta_inventario/*Adapted by JMM 20240308*/ ,costo, partida , var_st_compr/*Added by JMM 202040405*/ );
					*/
				
					-- Se eliminara el registro creado en la tabla de Ctrl de Costo al Inventario
					totalReg := 0;
					select count(*) into totalReg from keplersc.kdsunicosto  
					where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int
						and c6 = folio_operacion and st_x_comprobar = var_st_compr;
					if totalReg = 0 then
						mensajeError := 'No se encontro el Registro a Revertir en la Tabla { kdsunicosto } ...';
						raise exception '%',mensajeError;			
					end if;
				
					delete from keplersc.kdsunicosto where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int 
						and c6 = folio_operacion and st_x_comprobar = var_st_compr;

					totalReg := 0;
					select count(*) into totalReg from keplersc.kdsunicosto  
					where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int
						and c6 = folio_operacion and st_x_comprobar = var_st_compr;
					if abs(totalReg) > 0 then
						mensajeError := 'Se encontraron Inconsistencias al Eliminar el Registro en la Tabla { kdsunicosto } ...';
						raise exception '%',mensajeError;			
					end if;
				
				end if;
				
				*/ -- END : Commented Segment
			
			/*  -- N.A. for this option 20240404
			else
			
				---- Original Code (marked up) by JMM 20240308 
				if afecta_costo_inventario = 'S' then
				
					--Moved Up by JMM 20240308, para que aplique para ambas opciones
					/*
					if tipo_asiento_kdc = 'A' then
						costo := -(monto::numeric);
					else
						costo := monto::numeric;
					end if;
					*/
							
					insert into keplersc.kdsunicosto (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11) 
					values(sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,sucursal_id, inventario, cargo_abono_al_costo,costo, partida)	;
	
				end if;
			
			end if; -- if : upper(flag_contrarec)
			*/  -- N.A. for this option 20240404
		
		end loop;
	
		--Added by JMM 20240926
		if partidas_new <> 1 then 
			raise exception '%', 'El Documento No es Elegible para Revertir la Conversion como No Deducible, cuenta con ' || partidas_new || ' Partidas ' ;
		end if;
	
		-- ESTE SEGMENTO SE DEJO PARA OBTENER LA DSCR DEL CLIENTE COMO DESCRIPCION ALTERNA ...
		if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
		
			select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont;
			select * into resultado, mensaje, adicionales 
				from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			--En datos adicionales viene la cuenta calculada y el nombre del cliente/proveedor separado por |
			--raise exception '%,%,%', resultado, mensaje, adicionales ;
			--cuenta_cargo_kdc := split_part(adicionales, '|', 1);	
			/*tipo_asiento_1 := 'C'; tipo_asiento_2 := 'A';*/ -- Commented by JMM 20240404
		else
			--2
			select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont;
			select * into resultado, mensaje, adicionales 
				from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			--cuenta_abono_kdc := split_part(adicionales, '|', 1);
			/*tipo_asiento_1 := 'A'; tipo_asiento_2 := 'C';*/ -- Commented by JMM 20240404
		end if;
		clave_cuenta := split_part(adicionales, '|', 1);	
		nombre_cteprov :=  split_part(adicionales, '|', 2);
		-- END : SEGMENTO alta_cont_cont
	
		clave_cuenta := '';
		cuenta_dscr := '';
		-- Adapted by JMM 20240514, Se cambiaron para el efecto del Reverse de la poliza originada con la comprobacion
		tipo_asiento_1 := 'C' /*'A'*/; tipo_asiento_2 := 'A' /*'C'*/;
	
		-- CTA ABONO ... CTA PARAMETRO
		clave_cuenta := cuenta_abono_param;
	
		select * into resultado, mensaje, adicionales from keplersc.get_dscr_cuenta(clave_cuenta, anio);
		if resultado = '0' then
			raise exception '%', mensaje;
		else
			cuenta_dscr := mensaje;
		end if;

		cuenta_dscr := coalesce(cuenta_dscr, nombre_cteprov);
	
		-- To TEST 
		/*raise exception 'Movto, Cuenta : %', '[' || tipo_asiento_1 || '] , ' || clave_cuenta || ' , ' || cuenta_dscr;*/
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
    	--CONT(T,W9,B8000,B8090,W16,B8020,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_1 as tipo_asiento, 
			str_monto_total as monto,cuenta_dscr/*nombre_cteprov*/ as descrip, referencia as refer, 
			tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
			sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza, folio_poliza,
			numero_partida_poliza_kdc as numero_partida 
			, var_st_compr as var_st_compr /*Added by JMM 20240407*/)::text into strValor;
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	
		accion_poliza_kdc := '';
	
	
		-- CTA CARGO ... IVA
	
		-- N.A. para este Tipo de Documento
		/* -- START : Commented Segment

		if str_monto_iva > 0 then
		
			if length(trim(cuenta_contable_iva)) = 0 then 
				mensajeError := 'El Parametro de la Cuenta de Iva en KDMM No esta Registrado y para la Operacion es Requerido ... ';
				raise exception '%', mensajeError;
			end if;
		
			clave_cuenta := cuenta_contable_iva;
		
			select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(clave_cuenta, anio);
			if resultado = '0' then
				raise exception '%', mensaje;
			end if;
	
			select * into resultado, mensaje, adicionales from keplersc.get_dscr_cuenta(clave_cuenta, anio);
			if resultado = '0' then
				raise exception '%', mensaje;
			else
				cuenta_dscr := mensaje;
			end if;
	
			cuenta_dscr := coalesce(cuenta_dscr, nombre_cteprov);
		
			-- To TEST 
			/*raise exception 'Movto, Cuenta : %', '[' || tipo_asiento_2 || '] , ' || clave_cuenta || ' , ' || cuenta_dscr;*/
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, clave_cuenta/*cuenta_contable_iva*/ as cuenta, tipo_asiento_2 as tipo_asiento, 
				str_monto_iva as monto,cuenta_dscr/*nombre_cteprov*/ as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida 
				, var_st_compr as var_st_compr /*Added by JMM 20240407*/)::text into strValor;
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
			-- SEGMENTO APLICABLE SI EL DOC CONVERT TENIA ABONOS (PAGOS PREVIOS)
			if iva_acreditado > 0 then
			
				-- CTA ABONO ... IVA (DE LO PAGADO)
				
				clave_cuenta := cuenta_contable_iva;
				
				select * into resultado, mensaje, adicionales from keplersc.get_dscr_cuenta(clave_cuenta, anio);
				if resultado = '0' then
					raise exception '%', mensaje;
				else
					cuenta_dscr := mensaje;
				end if;
		
				cuenta_dscr := coalesce(cuenta_dscr, nombre_cteprov);
			
				-- To TEST 
				/*raise exception 'Movto, Cuenta : %', '[' || tipo_asiento_2 || '] , ' || clave_cuenta || ' , ' || cuenta_dscr;*/
			
				numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
				-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
				select xmlforest(fecha_operacion as fecha, clave_cuenta/*cuenta_contable_iva*/ as cuenta, 'C' /*'A'*/ as tipo_asiento, 
					iva_acreditado/*str_monto_iva*/ as monto,cuenta_dscr/*nombre_cteprov*/ as descrip, referencia as refer, 
					tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
					sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
					accion_poliza_kdc as accion_poliza, folio_poliza,
					numero_partida_poliza_kdc as numero_partida  
					, var_st_compr as var_st_compr /*Added by JMM 20240407*/)::text into strValor;
				select '<varcont>'||strValor||'</varcont>' into strValor;
				varcont := strValor::xml;
				select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
			
				-- CTA CARGO ... IVA (DE LO PAGADO)

				clave_cuenta := cuenta_iva_param;
				
				select * into resultado, mensaje, adicionales from keplersc.get_dscr_cuenta(clave_cuenta, anio);
				if resultado = '0' then
					raise exception '%', mensaje;
				else
					cuenta_dscr := mensaje;
				end if;
		
				cuenta_dscr := coalesce(cuenta_dscr, nombre_cteprov);
			
				-- To TEST 
				/*raise exception 'Movto, Cuenta : %', '[' || tipo_asiento_2 || '] , ' || clave_cuenta || ' , ' || cuenta_dscr;*/
			
				numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
				-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
				select xmlforest(fecha_operacion as fecha, clave_cuenta/*cuenta_contable_iva*/ as cuenta, 'A' /*'C'*/ as tipo_asiento, 
					iva_acreditado/*str_monto_iva*/ as monto,cuenta_dscr/*nombre_cteprov*/ as descrip, referencia as refer, 
					tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
					sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
					accion_poliza_kdc as accion_poliza, folio_poliza,
					numero_partida_poliza_kdc as numero_partida  
					, var_st_compr as var_st_compr /*Added by JMM 20240407*/)::text into strValor;
				select '<varcont>'||strValor||'</varcont>' into strValor;
				varcont := strValor::xml;
				select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
				if resultado = '0' then
					raise exception '%',mensaje;
				end if;
			
			end if;
		
		end if;
		
		*/ -- END : Commented Segment
	
		-- Codigo Implementado en el Segmento Anterior ... CTA CARGO IVA
		/*
		if cuenta_contable_iva <> '' and str_monto_iva <> 0 /*str_monto_iva <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_iva as cuenta, tipo_asiento_2 as tipo_asiento, 
				str_monto_iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
		*/
	
		-- * * * N.A. para Nueva Version de Contra-Recibos (Modulo Gastos)
		/*
		if (cuenta_contable_ieps <> '' or cuenta_contable_retencion_isr <> '') and str_monto_ieps_o_retencion_isr::numeric <> 0 /*str_monto_ieps_o_retencion_isr <> '0'*/ then 
		
			if genero = 'X' and naturaleza = 'A' and grupo = 12 and  cuenta_contable_retencion_isr <> '' then 
				cuenta_monto_ieps_o_retencion_isr := cuenta_contable_retencion_isr;
			else
				cuenta_monto_ieps_o_retencion_isr := cuenta_contable_ieps;
			end if;
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			select xmlforest(fecha_operacion as fecha, cuenta_monto_ieps_o_retencion_isr as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_monto_ieps_o_retencion_isr as monto,nombre_cteprov as descrip, referencia as refer, 
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
		*/
	
		-- * * * N.A. para Nueva Version de Contra-Recibos (Modulo Gastos)
		/*
		if  cuenta_contable_retencion_iva <> '' and str_retencion_iva::numeric <> 0 /*str_retencion_iva <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		--  CONT(T,W9,M64,B8090,W23,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_retencion_iva as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_retencion_iva as monto,nombre_cteprov as descrip, referencia as refer, 
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
		*/
	
		-- * * * N.A. para Nueva Version de Contra-Recibos (Modulo Gastos)
		/*
		if  cuenta_contable_otras_retenciones <> '' and str_otras_retenciones::numeric <> 0 /*str_otras_retenciones <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--  CONT(T,W9,M74,B8090,W49,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_otras_retenciones as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_otras_retenciones as monto,nombre_cteprov as descrip, referencia as refer, 
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
		*/
	
	end if;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_doc_convert_no_deduc_rollback() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
