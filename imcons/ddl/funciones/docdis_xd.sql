CREATE OR REPLACE FUNCTION keplersc.docdis_xd(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos X, A (Cuentas por Pagar, Deudoras)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Victor Salgado
	--Fecha: 27 Junio 2022
	--12/03/2024 (JMM) :
	---- Se incluyen validaciones en Contabilidad para el Nuevo Esquema de Gastos ( CxP ) 
	--13/03/2025 Victor Salgado: Se elimina validacions para obetncion de folio
	--26/09/2025 Víctor Salgado: Se integar impuestos Impuestos ISR, IEPS y Cedulares

	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;

	--VCSS 26/09/2025 
	concepto_factura text ='';

	--xml Movimiento
	xmlKDM1 xml;


	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	strResumen text = '';

	valida_devoluciones int;
	ST_Compra_AUT int;
	TMov_Invent_AUT int;

	--Added by JMM 20240305 (Ctrl Gastos CxP)
	flag_gastos text = '';

	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;
		
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin

	-- Inicializacion de variables
	folio_operacion := '0'; --0 /*20220724*/
	get_resultado := '';
	get_adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	concepto_factura:= coalesce((xpath('//document/uuid/concepto_factura/text()',dataxml))[1]::text,'')::text;

/*
 * CUENTAS POR PAGAR Genero 'X'
*/

	valida_devoluciones := 0;

	if genero = 'X' and naturaleza = 'D' then --Cuentas por pagar, Acredora	
	
	
		--Moved here by JMM 20241011 
		flag_gastos = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;

		-- Added by JMM 20241011 
		-- * * *  VALIDACION DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
		if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
		
			paso:= 'docdis_xd.gpogasto_validacion';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_validacion(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		
		else 
		
			--  * * *  EJECUTA TODAS LAS VALIDACIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241011
	
	
			if grupo = '40' and tipo = '1' then
				valida_devoluciones = 1;
			end if;
	
			-- UPD by JMM 20221118 (UPD condition to control entry)  
			if grupo <> '31' and grupo <> '33' and grupo <> '36'  --Cheques y  VCSS Transferencias  
				and (upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN' and grupo <> '6' and grupo <> '7')
			then
				-- VALIDAR TOTALES Y DATOS GENERALES DE DOCTOS  ... PARA CUALQUIER X_D 
				paso:= 'docdis_xd.valida_operacion_documentos';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_documentos(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			end if;
		
			-- NEW  by JMM 20221118 (UPD condition to control entry) 
			if ( (grupo = '6' or grupo = '7') and upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN' ) then
				-- Para UEN = AUT & GPO = 6 No debe entrar a la validacion 
				
			else 
				-- Original code 
				if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' then
					-- VALIDAR INVENTARIO ... PARA CUALQUIER X_D 
					paso:= 'docdis_xd.valida_operacion_inventarios';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_inventarios(dataxml);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				end if;
			end if; 
	
			-- VALIDAR DEVOLUCIONES COMPRA ... PARA LOS CASOS QUE APLICA ... 
			-- Se debe incluir el PARAM del Tipo_Compra que aplique (1..3)
			-- Actual : if grupo = '40' and tipo = '1'  
			if valida_devoluciones = 1 then
				paso:= 'docdis_xd.valida_operacion_devoluciones_compras';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_devoluciones_compras(dataxml, 1/*Tipo_Compra*/);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			end if;
	
			---------------------------------------------------------------
			--Validacion de la Nota de Cr�dito Y Anulacion
			---------------------------------------------------------------
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_nota_credito_anulacion(dataxml, xmlkdmm);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
	
		
		end if;  --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241011
		
		
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
	
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento
--		if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
			--TO DO: Realizar para esta condicion... y el llamado a CALL CFD_GUARDA_FOLIO
		
--		else
				--TO DO:Validar de donde se obtienen los adicionales c2 y c3, se estan mandando 0 y 0 por default, pero no es asi para todos
				paso := 'docdis.obtener_folio_documento';
	
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0, dataxml);
			
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_operacion := get_mensaje;

--		end if;
	
	
		--For Testing by JMM 20241008
		/*raise exception '%', 'Folio Operacion : ' || folio_operacion;*/
	
		
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm1.
		--Resuelve: ALTA_MOV_PRIM_SFOLIO 
		---------------------------------------------------------------
		paso:= 'docdis_xd.mov_prim_alta';
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_alta(dataxml, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
raise notice '%',paso; 	
		---------------------------------------------------------------
		--FIN INVENTARIOS. Registro de movimiento en kdm1
		---------------------------------------------------------------	
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
		if  (
			(xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or 
			(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S' or 
			(xpath('//row/c86/text()', xmlKDMM))[1]::text = 'C' 
			)
			-- This condition is new ... 221012 ... JMM ... Se incluyeron parentesis predecesores ... 
			-- Aplica para UEN AUT 
			and (grupo <> '6' and grupo <> '7') 
			
		then
			if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
				paso:= 'docdis_xd.gpogasto_validacion';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_validacion(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			end if;

			paso:= 'docdis_xd.mov_sec_alta';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		
		else
		
			---------------------------------------------------------------
			--MOVIMIENTOS. Registro de movimientos en kdm6.
			--Resuelve: ALTA_DOC_SEC 
			---------------------------------------------------------------
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S'  then
				paso:= 'docdis.alta_doc_sec';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_doc_sec(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;

				---------------------------------------------------------------
				--MOVIMIENTOS. Registro de movimientos contables en kdm6.
				--Resuelve: ALTA_CONT_SEC 
				--Victor Salgado. Se agrega validacion concepto_factura para impuestos
				---------------------------------------------------------------
				if  (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' and
					((xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' or concepto_factura <> '' ) then
					paso:= 'docdis.alta_cont_sec';
--raise exception '%',paso;
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_sec(dataxml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
				end if;			
			else
			
				--MOVIMIENTOS. Registro de movimientos contables en kdm6.
				--Resuelve: ALTA_CONT_SEC 
				---------------------------------------------------------------
				if  (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' and
				   (xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' then
					paso:= 'docdis.alta_cont_sec';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_sec(dataxml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
--raise notice '%',paso;			
				end if;
		
			end if;
			
		end if;	

		---------------------------------------------------------------
		--FIN INVENTARIOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
	
	
		-- Moved here for JMM ... 20240304 ... 
		--Obtener xml de KDM1 de registro generado 		
		expSql = 'select * from keplersc.kdm1 where' || 
			' c1=' || E'\'' || sucursal_id || E'\'' ||  
			' and c2=' || E'\'' || genero || E'\'' ||
			' and c3=' || E'\'' || naturaleza || E'\'' || 
			' and c4=' || grupo || 
			' and c5=' || tipo ||
			' and c6=' || E'\'' || folio_operacion || E'\'';

		select query_to_xml(expSql, true, false, '') into xmlKDM1;
	
	
		-- This condition is new ... 221118 ... JMM ...
		---------------------------------------------------------------
		-- COMPRAS E INVENTARIOS - AUTOS 
	    -- Aplica para Proceso de Negocios (UEN) - AUTOS 
		---------------------------------------------------------------
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and  
			(xpath('//row/c65/text()', xmlKDMM))[1]::text > '0' and 
			upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN' 
		then
			
			if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '10' and 
				(xpath('//row/c1/text()', xmlKDMM))[1]::text = 'X' 	
			then -- COMPRA 

				-- Se incluye validacion (funcion ya realizada por Saltiel) ... 221122 
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_invalta(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;							
			
				ST_Compra_AUT := null;
				if (xpath('//row/c2/text()', xmlKDMM))[1]::text = 'A' then 
					ST_Compra_AUT := 0; -- "Alta Compra"  
				end if; 
				if (xpath('//row/c2/text()', xmlKDMM))[1]::text = 'D' then 
					ST_Compra_AUT := 10; -- "Baja Compra"  
				end if; 
				if ST_Compra_AUT is null then 
					get_mensaje := 'Tipo de Documento No Soportado ...';
					raise exception '%',get_mensaje;
				end if;
				paso:= 'docdis.autos_inv_compra';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.autos_inv_compra(dataxml, xmlKDM1, folio_operacion, ST_Compra_AUT);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
				TMov_Invent_AUT := null;
				if (xpath('//row/c2/text()', xmlKDMM))[1]::text <> 'D' then
					TMov_Invent_AUT := 0; -- "Entrada".Inventario 
				end if;
				if (xpath('//row/c2/text()', xmlKDMM))[1]::text = 'D' then
					TMov_Invent_AUT := 10; -- "Salida".Inventario 
				end if;
				if TMov_Invent_AUT is null then 
					get_mensaje := 'Tipo de Movimiento No Soportado ...';
					raise exception '%',get_mensaje;
				end if;
				paso:= 'docdis.autos_inv_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.autos_inv_alta(dataxml, xmlKDM1, folio_operacion, TMov_Invent_AUT);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;		
			
				paso:= 'docdis.autos_inv_alta_k';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.autos_inv_alta_k(dataxml, xmlKDM1, folio_operacion, TMov_Invent_AUT);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
				paso:= 'docdis.autos_inv_status';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.autos_inv_status(dataxml, xmlKDM1, xmlKDMM);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;			
			
				/*
				get_mensaje = 'Paso OK por la opcion [AUT].Inv_Compra , [AUT].Inv_Alta , [AUT].Inv_Alta_K , [AUT].Inv_Status / JMM';
				raise exception '%',get_mensaje;
				*/
			
			end if;
		
		end if;
		---------------------------------------------------------------		
		--FIN COMPRAS E INVENTARIOS - AUTOS
		---------------------------------------------------------------
	
	
	   ---------------------------------------------------------------
		-- Cuentas por Cobara y/o Pagar CXCPLIB.ALTA_CxCP, ejecuta:
		--    k75:CXCPLIB.ALTA_CXCP.CXCP_SUSTITUCION
		--    k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_SINMOV
		--    k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_CONMOV		
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text  = 'S' then --Afecta Cuentas por Cobrar o Pagar
		
			-- Added by JMM 20241011 
			-- * * *  GESTION DE MONTOS DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
			if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
		
				paso:= 'docdis_xd.gpogasto_actualiza_montos';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_actualiza_montos(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
			else 
			
				--  * * *  EJECUTA TODAS LAS FUNCIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241011
			
				--CXCP_SUSTITUCION			
				if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S'  --Gen CFD
					and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'S' then --Abrir campo Importe
					--TO DO: Desarrollar CXPLIB.CXCP_SUSTITUCION				
				end if; --FIN CXCP_SUSTITUCION
				
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
					--CXCP_ALTA_CONMOV
					paso:= 'docdis_xd.cxcp_alta_conmov';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_alta_conmov(dataxml, xmlKDMM, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
raise notice '%',paso;				
				else				
					--CXCP_ALTA_SINMOV
					paso:= 'docdis_xd.cxcp_sinmov_kduxe_alta';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxe_alta(dataxml, xmlKDMM, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;					
				
					paso:= 'docdis_xd.cxcp_sinmov_kduxg_alta';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxg_alta(dataxml, get_adicionales::xml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
	
				end if;
				--FIN CXCP_ALTA_CONMOV
			
			end if; --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241011
		
		end if;
		---------------------------------------------------------------		
		--FIN CxCP
		---------------------------------------------------------------

		-- Included by JMM 20220712 (gotten of Docdis_XA)
		--------------------------------------------------------------------
		--INVENTARIOS
		--Registros en : kdinm; kdink, kdinl, kdreflastmov (Estadisticas)
		---------------------------------------------------------------------
	
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --Afecta Inventarios
			((xpath('//row/c52/text()', xmlKDMM))[1]::text is null or (xpath('//row/c52/text()', xmlKDMM))[1]::text <> 'S')  and --Maneja Backorder
			((xpath('//row/c83/text()', xmlKDMM))[1]::text is null or (xpath('//row/c83/text()', xmlKDMM))[1]::text <> 'S') and --Backorder
			((xpath('//row/c84/text()', xmlKDMM))[1]::text is null or (xpath('//row/c84/text()', xmlKDMM))[1]::text <> 'S')  --Abrir campo Importe TO DO: Verifcar desino del campo

			-- This condition is new ... 221118 ... JMM   
			-- Aplica para UEN AUT 
			and (grupo <> '6' and grupo <> '7') 
			
			then
				paso:= 'docdis_xd.invr_movtos_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_movtos_alta(dataxml,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
		end if;		
		---------------------------------------------------------------
		--FIN INVENTARIOS
		---------------------------------------------------------------	
		
	
		--TO DO: Development & Implementing : k75:INVRLIB_ALTA_VENCOM 
		-- Included by JMM 20220712 
		--------------------------------------------------------------------------
		--INVENTARIOS
		--Registros en : kdvcm, kdvobs, kdvck 
	   --Resuelve o Ejecuta :  k75 -> INVRLIB_ALTA_VENCOM
		--------------------------------------------------------------------------
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --Afecta Inventarios
		   (xpath('//row/c1/text()', xmlKDMM))[1]::text <> 'N' and --Genero 
			((xpath('//row/c52/text()', xmlKDMM))[1]::text is null or (xpath('//row/c52/text()', xmlKDMM))[1]::text <> 'S')  and --Maneja Backorder
			((xpath('//row/c83/text()', xmlKDMM))[1]::text is null or (xpath('//row/c83/text()', xmlKDMM))[1]::text <> 'S') and --Backorder
			((xpath('//row/c84/text()', xmlKDMM))[1]::text is null or (xpath('//row/c84/text()', xmlKDMM))[1]::text <> 'S')  --Abrir campo Importe TO DO: Verifcar destino del campo
			
			-- This condition is new ... 221118 ... JMM  
			-- Aplica para UEN AUT  
			and (grupo <> '6' and grupo <> '7')  		
			
		then
				paso:= 'docdis_xd.invr_alta_vencom';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_alta_vencom(dataxml,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
		end if;		
		---------------------------------------------------------------
		--FIN INVENTARIOS
		---------------------------------------------------------------		
		-- END cmnt by JMM ... */

	   --cmnt(2).free4eg by JMM
		--raise exception '%',folio_operacion;
	
	
		-- CALL INV_ALTA_NOTA_CREDITO
		paso:= 'docdis.ALTA_NOTA_CREDITO';
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_nota_credito_anulacion(dataxml, xmlkdmm, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	
	
	
		---------------------------------------------------------------
		--CONTABILIDAD. ALTA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
			if upper(flag_gastos) = 'CXP_PAGO' or upper(flag_gastos) = 'CXP_TRANSFER'/*Added by JMM 20240312*/ then
				if concepto_factura = '' then
					paso:= 'docdis_xd.alta_cont_gastos';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_gastos(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
				else
					paso:= 'docdis_xd.alta_cont_cont';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_transfer(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				end if;
			else 
		
				-- Original Code (marked up) by JMM 20240305 
				if (xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' then --Pantalla c/movtos contables
					-- CONTLIB.ALTA_CONT_CONT
				else
					if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
					
						-- Added by JMM 20241011 ... As Validation for Internal Docs
						if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
						
							raise exception '%','La opcion  [alta_cont_mov]  No esta permitida para los Documentos Internos' || ' | ' || ' ' || ' | ' || 'Parametro C47 en KDMM';
						
						else
					
							-- Original Code (marked up) by JMM 20241011
							paso:= 'docdis_xd.alta_cont_mov';
							select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_mov(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
							if get_resultado = '0' then
								raise exception '%',get_mensaje;
							end if;
raise notice '%',paso;						
						end if; -- IF ... ELSE / INTERNAL DOCs Added by JMM 20241011
					
					else
						paso:= 'docdis_xd.cont_general_alta';
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
						strResumen:=strResumen || '|' || get_adicionales;				
					end if;					
				end if;
			
			end if; -- if : upper(flag_gastos)
		end if;	
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		---------------------------------------------------------------	
	
		
	end if; ---*** Genero, Naturaleza
	
--raise exception 'VCSS Error inyectado docdis_xd %',folio_operacion;
	get_resultado:='1';
	get_mensaje:=folio_operacion;
	get_adicionales:=strResumen;
	return query select get_resultado, get_mensaje, get_adicionales;

END;
$function$
