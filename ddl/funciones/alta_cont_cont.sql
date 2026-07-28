CREATE OR REPLACE FUNCTION keplersc.alta_cont_cont(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci?n de movimientos contables
--Autor: Luis Leal
--Fecha: 09/10/22
--Bitacora de cambios
--08/03/2024 (JMM) :
---- Se incluyen cambios asociados con nuevo SCH - Gastos ( C x P ) 
---- para las Operaciones de los Comtrarecibos 
--17/07/2024 (JMM) : 
---- Incluir Concepto Presupuesto para nuevo SCH - Gastos ( C x P . Contra Recibos) 
--15/10/2024 (JMM) : 
---- Incluir Opciones para Manejo de CR - Interno para nuevo SCH - Gastos ( C x P . Contra Recibos) 

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
	--sumas
	str_monto_iva := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0')::text; 	
	str_monto_ieps_o_retencion_isr := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0')::text; 	
	str_retencion_iva:= coalesce((xpath('//row/c23/text()', xmlkdm1))[1]::text,'0')::text; 		
	str_otras_retenciones := coalesce((xpath('//row/c49/text()', xmlkdm1))[1]::text,'0')::text; 		
	str_monto_total := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0')::text; 
	--cuentas contables
 	cuenta_contable_iva := (xpath('//row/c21/text()', xmlKDMM))[1]::text;
  	cuenta_contable_ieps := (xpath('//row/c23/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_isr := (xpath('//row/c22/text()', xmlKDMM))[1]::text;
 	cuenta_contable_retencion_iva := (xpath('//row/c64/text()', xmlKDMM))[1]::text;
  	cuenta_contable_otras_retenciones := (xpath('//row/c74/text()', xmlKDMM))[1]::text;
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;
	afecta_costo_inventario := (xpath('//row/c77/text()', xmlKDMM))[1]::text;
	cargo_abono_al_costo := (xpath('//row/c67/text()', xmlKDMM))[1]::text;


	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);

	folio_poliza := 'POLIZA' || tipo_poliza_kdmm || anio_en_curso || mes_en_curso ;

	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_poliza);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;

	accion_poliza_kdc := 'NUEVAPOLIZA';

	if (xpath('//row/c6/text()', xmlKDMM))[1]::text  = 'S' and (xpath('//row/c71/text()', xmlKDMM))[1]::text  = 'S' then 
	
		for partida,clave_cuenta,descr_cuenta,tipo_asiento_kdc,monto,inventario ,afectacion/*Added by JMM 20240308*/ 
			,concept_prspto /*Added by JMM 20240717*/
			in select c7,c8,c9,c10,c11,c13 ,c12/*Added by JMM 20240308*/ ,ctopto/*Added by JMM 20240717*/
			from keplersc.kdm6 
			where c1 = suc_id and c2 = genero and c3 = naturaleza and c4 = grupo and c5 = tipo_clave and c6 = folio_operacion
		loop 

			--Moved here by JMM 20240717 
			flag_contrarec = '';
			if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
				flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
			end if;
			
			--Added by JMM 20240717 
			var_concept_prspto := '';
		
			--Adapted by JMM 20241015 
			if upper(flag_contrarec) in /*=*/ ('CXP_CONTR_REC','CXP_CONTR_REC_INTERNO') then
				var_concept_prspto := coalesce(concept_prspto,'');
			end if;
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--CONT(T,W9,X8,X10,X11,X9,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_kdc as tipo_asiento, 
				monto,descr_cuenta as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida
				, var_concept_prspto as var_concept_prspto /*Added by JMM 20240717*/)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
		
			--Moved here by JMM 20240717, para que aplique para ambas opciones
			if tipo_asiento_kdc = 'A' then
				costo := -(monto::numeric);
			else
				costo := monto::numeric;
			end if;
		
			--Commented & Moved Up by JMM 20240717 
			/*
			--Added by JMM 20240308
			flag_contrarec = '';
			if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
				flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
			end if;
			*/
		
			--Adapted by JMM 20241015 
			if upper(flag_contrarec) in /*=*/ ('CXP_CONTR_REC','CXP_CONTR_REC_INTERNO') then 
			
				afecta_inventario = '';
				if length(trim(inventario)) > 0 then
				
					afecta_inventario := afectacion;
					if length(trim(afecta_inventario)) = 0 then
						mensaje := 'No se cuenta con la afectacion para el inventario registrado ' || inventario || ' , partida ' || partida::text;
						raise exception '%' , mensaje;
					end if;
				
					-- For Testing ...
					--raise exception '%''%''%''%''%',inventario,' - ',afecta_inventario,' - ',partida;
				
					insert into keplersc.kdsunicosto (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11) 
					values(suc_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,suc_id, inventario, afecta_inventario/*Adapted by JMM 20240308*/ ,costo, partida)	;
	
				end if;
			
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
					values(suc_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,suc_id, inventario, cargo_abono_al_costo,costo, partida)	;
	
				end if;
			
			end if; -- if : upper(flag_contrarec)
		
		
		end loop;
	
	
		if (xpath('//row/c2/text()', xmlKDMM))[1]::text  = 'D' then
		
			select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont;
			select * into resultado, mensaje, adicionales 
				from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			--En datos adicionales viene la cuenta calculada y el nombre del cliente/proveedor separado por |
			--raise exception '%,%,%', resultado, mensaje, adicionales ;
			--cuenta_cargo_kdc := split_part(adicionales, '|', 1);	
			tipo_asiento_1 := 'C'; tipo_asiento_2 := 'A';
		else
			--2
			select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont;
			select * into resultado, mensaje, adicionales 
				from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
			--cuenta_abono_kdc := split_part(adicionales, '|', 1);
			tipo_asiento_1 := 'A'; tipo_asiento_2 := 'C';
		end if;
		clave_cuenta := split_part(adicionales, '|', 1);	
		nombre_cteprov :=  split_part(adicionales, '|', 2);
	
		numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
    	--CONT(T,W9,B8000,B8090,W16,B8020,W11,M18,"","","","","",W1...W6,B8095)
		select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_1 as tipo_asiento, 
			str_monto_total as monto,nombre_cteprov as descrip, referencia as refer, 
			tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
			suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza, folio_poliza,
			numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	
	
		-- Added by JMM 20241015 
		-- START : New Section - 'CXP_CONTR_REC_INTERNO'
		if upper(flag_contrarec) in ('CXP_CONTR_REC_INTERNO') then 
		
			cuenta_prov_int := '';
			cuenta_prov_int_dscr := '';
			prov_int := '';
			clave_gpogasto := '';
			cuenta_iva_param := '';
	
			-- Corresponde a Netear el Abono del Proveedor de la Operacion, para el DOC {CR-Interno}
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
	    	--CONT(T,W9,B8000,B8090,W16,B8020,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_2 as tipo_asiento, 
				str_monto_total as monto,nombre_cteprov as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
	
			cuenta_prov_int := coalesce((xpath('//row/c20/text()', xmlKDMM))[1]::text,'')::text;
		
			cuenta_prov_int := trim(cuenta_prov_int);
		
			if xpath_exists('//document/k_gpo_gasto/text()', dataxml) = true /*false*/ then 
				clave_gpogasto := coalesce((xpath('//document/k_gpo_gasto/text()',dataxml))[1]::text,'')::text;
			end if;
		
			if length(clave_gpogasto) = 0 then
				mensajeError := 'No se pudo obtener el Grupo de Gasto del Documento ...';
				raise exception '%',mensajeError;
			end if;
		
			select proveedor_id into prov_int from keplersc.kdgpcontra where suc_id = suc_id and grupo_id = clave_gpogasto::int
				and estatus = 'A';
		
			prov_int := trim(coalesce(prov_int,''));
		
			if length(prov_int) = 0 then
				mensajeError := 'No se pudo obtener el Proveedor del Grupo de Gasto ...';
				raise exception '%',mensajeError;
			end if;
		
			select coalesce(c3,'NotFoundProvInt') into cuenta_prov_int_dscr from keplersc.kdxd where c2 = prov_int and interno = 1;
		
			cuenta_prov_int_dscr := (cuenta_prov_int_dscr);
		
			if length(cuenta_prov_int_dscr) = 0 then 
				mensajeError := 'No se pudo obtener la Descripcion del Proveedor Interno asociado al Grupo de Gasto ...';
				raise exception '%',mensajeError;
			end if;
		
			if length(cuenta_prov_int) = 0 then
				cuenta_prov_int := prov_int;
			else
				cuenta_prov_int := cuenta_prov_int || '-' || prov_int;
			end if;
		
			--For Testing ...
			--raise exception 'CtaProvInt %  DscrProvInt % ', cuenta_prov_int, cuenta_prov_int_dscr; 
		
			-- Corresponde al Abono del Proveedor Interno asociado al Gpo de Gasto, para el DOC {CR-Interno}
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
	    	--CONT(T,W9,B8000,B8090,W16,B8020,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_prov_int as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_monto_total as monto,cuenta_prov_int_dscr as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
			-- Added by JMM 20241016
			-- Manejo CTA IVA ACREDITABLE
			if str_monto_iva::numeric <> 0 /*iva_acreditado > 0*/ then

				select p.* into recp from keplersc.param_oper p 
				where p.sucursal = suc_id and upper(p.parametro) = upper(trim('Cuenta Gastos Iva Acreditable'));
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
			
				select * into resultado, mensaje, adicionales from keplersc.verify_cuenta_ult_nivel(cuenta_iva_param, anio_en_curso);
				if resultado = '0' then
					raise exception '%', mensaje;
				end if;
			
				cuenta_contable_iva := cuenta_iva_param;  -- { CTA IVA X ACREDITAR } REPLACED BY { CTA IVA ACREDITABLE } 
		
			end if;
		
		end if;
		-- END : New Section - 'CXP_CONTR_REC_INTERNO'
	
	
		--For Testing ... 20241016 by JMM 
		--raise exception 'CtaIVA %  MontoIVA % ', cuenta_contable_iva, str_monto_iva::numeric; 
	
	
		accion_poliza_kdc := '';
	
		if cuenta_contable_iva <> '' and str_monto_iva::numeric <> 0 /*str_monto_iva <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			-- CONT(T,W9,M21,B8091,W14,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_iva as cuenta, tipo_asiento_2 as tipo_asiento, 
				str_monto_iva as monto,nombre_cteprov as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
		end if;
	
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
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
		end if;
	
		if  cuenta_contable_retencion_iva <> '' and str_retencion_iva::numeric <> 0 /*str_retencion_iva <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
		--  CONT(T,W9,M64,B8090,W23,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_retencion_iva as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_retencion_iva as monto,nombre_cteprov as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
				accion_poliza_kdc as accion_poliza, folio_poliza,
				numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
			select '<varcont>'||strValor||'</varcont>' into strValor;
			varcont := strValor::xml;
			select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
			if resultado = '0' then
				raise exception '%',mensaje;
			end if;
		
		end if;
	
		if  cuenta_contable_otras_retenciones <> '' and str_otras_retenciones::numeric <> 0 /*str_otras_retenciones <> '0'*/ then 
		
			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--  CONT(T,W9,M74,B8090,W49,W32,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, cuenta_contable_otras_retenciones as cuenta, tipo_asiento_1 as tipo_asiento, 
				str_otras_retenciones as monto,nombre_cteprov as descrip, referencia as refer, 
				tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
				suc_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
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

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'alta_cont_cont() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
