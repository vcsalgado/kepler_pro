CREATE OR REPLACE FUNCTION keplersc.alta_cont_cont(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Descripcion: Realiza inserci�n de movimientos contables
--Autor: Luis Leal
--Fecha: 09/10/22
--Bitacora de cambios
--08/03/2024 (JMM) :
---- Se incluyen cambios asociados con nuevo SCH - Gastos ( C x P ) 
---- para las Operaciones de los Comtrarecibos 

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
			in select c7,c8,c9,c10,c11,c13 ,c12/*Added by JMM 20240308*/ from keplersc.kdm6 
			where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo and c5=tipo_clave and c6=folio_operacion
		loop 

			numero_partida_poliza_kdc = numero_partida_poliza_kdc + 1;
			--CONT(T,W9,X8,X10,X11,X9,W11,M18,"","","","","",W1...W6,B8095)
			select xmlforest(fecha_operacion as fecha, clave_cuenta as cuenta, tipo_asiento_kdc as tipo_asiento, 
				monto,descr_cuenta as descrip, referencia as refer, 
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
		
		
			--Moved here by JMM 20240308, para que aplique para ambas opciones
			if tipo_asiento_kdc = 'A' then
				costo := -(monto::numeric);
			else
				costo := monto::numeric;
			end if;
		
		
			--Added by JMM 20240308
			flag_contrarec = '';
			if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
				flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
			end if;
		
			if upper(flag_contrarec) = 'CXP_CONTR_REC' then 
			
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
					values(sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,sucursal_id, inventario, afecta_inventario/*Adapted by JMM 20240308*/ ,costo, partida)	;
	
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
					values(sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion,sucursal_id, inventario, cargo_abono_al_costo,costo, partida)	;
	
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
			sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza, folio_poliza,
			numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	
		accion_poliza_kdc := '';
	
		if cuenta_contable_iva <> '' and str_monto_iva::numeric <> 0 /*str_monto_iva <> '0'*/ then 
		
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
