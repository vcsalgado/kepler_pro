CREATE OR REPLACE FUNCTION keplersc.docdis_xa(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos X, A (Cuentas por Pagar, Acreedoras)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Victor Salgado
	--Fecha: 27 Junio 2022
	--Update : 20241015 by JMM 
	--Implementing NEW OPC for Expenses SCH {Internal Docs} 
	--13/03/2025 Victor Salgado: Se elimina validacions para obetncion de folio
	--25/07/2025 Miriam Santana: Agregar el llamado a la funcion alta_cont_mov en la condicion kdmm.c47='S'	

	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	uen text = '';
	kodawari text;

	--xml Movimiento
	xmlKDM1 xml;


	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	strResumen text = '';

	ST_Compra_AUT int;
	TMov_Invent_AUT int;

	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;

	--Added by JMM 20241015 (Ctrl Gastos CxP)
	flag_gastos text = '';
		
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	
begin
	-- Inicializacion de variables
	folio_operacion := 0;
	get_resultado := '';
	get_adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');	

	if genero = 'X' and naturaleza = 'A' then --Cuentas por pagar, Acredora		
		
		--Moved here by JMM 20241011 
		flag_gastos = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;

		-- Added by JMM 20241015 
		-- * * *  VALIDACION DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
		if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
		
			paso:= 'docdis_xd.gpogasto_validacion';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_validacion(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		
		else 
		
			--  * * *  EJECUTA TODAS LAS VALIDACIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241015 
	
			-- VALIDAR TOTALES Y DATOS GENERALES DE DOCTOS  ... PARA CUALQUIER X_A
			-- Implemented by JMM ... 220726 
		
			--if (grupo <> '55' and tipo <> '1') and (grupo <> '12') then
			--UPD : JMM ... 221118 	
			if uen = 'REF' then
				if (grupo <> '55' and tipo <> '1') and (grupo <> '12') 
					and (grupo <> '6' or upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) <> 'VEN') 
					and (grupo <> '7'or upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) <> 'VEN') 
				then
				
					paso:= 'docdis_xa.valida_operacion_documentos';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_documentos(dataxml);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				end if;
			end if;
	
			---------------------------------------------------------------
			--Validacion de la alta de cxp o cxc
			---------------------------------------------------------------
			if (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' then		--Afecta cxcp
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_cxcp_alta(dataxml,xmlkdmm);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			end if;
		
		
		end if;  --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241015 
	
	
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento
		strValor := (xpath('//row/c93/text()', xmlKDMM))[1];
--		if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
			--TO DO: Realizar para esta condicion... y el llamado a CALL CFD_GUARDA_FOLIO
--		else
--			if strValor is null or strValor <> 'S' then		--Valida c93
				--TO DO:Validar de donde se obtienen los adicionales c2 y c3, se estan mandando 0 y 0 por default, pero no es asi para todos
				paso := 'docdis.obtener_folio_documento';
	
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0, dataxml);
			
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_operacion := get_mensaje;

--			end if;
--		end if;
		
		---------------------------------------------------------------
		--MOVIMIENTOS. Registro de movimiento en kdm1.
		--Resuelve: ALTA_MOV_PRIM_SFOLIO 
		---------------------------------------------------------------
		paso:= 'docdis.mov_prim_alta';
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_alta(dataxml, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		--Obtener xml de KDM1 de registro generado 
		expSql=format('select * from keplersc.kdm1 where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L',
			sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion );
		select query_to_xml(expSql, true, false, '') into xmlKDM1;

--raise notice '%',xmlKDM1;
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
		if  (
			(xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or 
			(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c86/text()', xmlKDMM))[1]::text = 'C' --then
			)
			-- This condition is new ... 221012 ... JMM ... Se incluyeron parentesis predecesores ...
			and (grupo <> '6' or upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) <> 'VEN') 
			and (grupo <> '7' or upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) <> 'VEN')
			
		then 
			paso:= 'docdis.mov_sec_alta';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		
		else
		
			---------------------------------------------------------------
			--MOVIMIENTOS. Registro de movimientos en kdm5.
			--Resuelve: ALTA_DOC_SEC 
			---------------------------------------------------------------
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S'  then
			
				paso:= 'docdis.alta_doc_sec';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_doc_sec(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
			else
				---------------------------------------------------------------
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
				end if;
			end if;
			
		end if;	
	
	
	
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
		--TOTs Registro de movimiento en kdtot
		---------------------------------------------------------------
		if genero = 'X' and naturaleza = 'A' and grupo = '55' and tipo = '1' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.ser_tots_crud(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
		end if;
		---------------------------------------------------------------
		--Cuentas por Cobara y/o Pagar CXCPLIB.ALTA_CxCP, ejecuta:
		--k75:CXCPLIB.ALTA_CXCP.CXCP_SUSTITUCION
		--k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_SINMOV
		--k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_CONMOV		
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text  = 'S' then --Afecta Cuentas por Cobrar o Pagar
		
			-- Added by JMM 20241015 
			-- * * *  GESTION DE MONTOS DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
			if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
		
				paso:= 'docdis_xd.gpogasto_actualiza_montos';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_actualiza_montos(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
			else 
			
				--  * * *  EJECUTA TODAS LAS FUNCIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241015
			
				--CXCP_SUSTITUCION			
				if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S'  --Gen CFD
					and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'S' then --Abrir campo Importe
					--TO DO: Desarrollar CXPLIB.CXCP_SUSTITUCION				
				end if; --FIN CXCP_SUSTITUCION
							
				--CXCP_ALTA_SINMOV
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text <> 'S' then --Pantalla movimientos CXP			
					--CXCP_ALTA_SINMOV
					paso:= 'docdis.cxcp_sinmov_kduxe_alta';
--raise exception 'PASO:%',paso;
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxe_alta(dataxml, xmlKDMM, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;					
				
					paso:= 'docdis.cxcp_sinmov_kduxg_alta';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxg_alta(dataxml, get_adicionales::xml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				
				end if;	
				--FIN CXCP_ALTA_SINMOV
		
				--CXCP_ALTA_CONMOV
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
				
					paso:= 'docdis.cxcp_alta_conmov';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_alta_conmov(dataxml, xmlKDMM, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				
				end if;
				--FIN CXCP_ALTA_CONMOV
			
			
			end if; --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241015 
			
		
		end if;
		---------------------------------------------------------------		
		--FIN CxCP
		---------------------------------------------------------------
	

		---------------------------------------------------------------
		--INVENTARIOS
		---------------------------------------------------------------
		if uen = 'REF' then
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --Afecta Inventarios
				((xpath('//row/c52/text()', xmlKDMM))[1]::text is null or (xpath('//row/c52/text()', xmlKDMM))[1]::text <> 'S')  and --Maneja Backorder
				((xpath('//row/c83/text()', xmlKDMM))[1]::text is null or (xpath('//row/c83/text()', xmlKDMM))[1]::text <> 'S') and --Backorder
				((xpath('//row/c84/text()', xmlKDMM))[1]::text is null or (xpath('//row/c84/text()', xmlKDMM))[1]::text <> 'S')  --Abrir campo Importe TO DO: Verifcar desino del campo
								
				then 			
					paso:= 'docdis.invr_movtos_alta';			
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_movtos_alta(dataxml,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
				
					paso:= 'docdis.invr_alta_vencom';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_alta_vencom(dataxml,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				
			end if;	
		end if;
		---------------------------------------------------------------
		--FIN INVENTARIOS
		---------------------------------------------------------------		
	
		---------------------------------------------------------------
        -- REFACCIONES : ALTA_BACKORDER (Added by JMM 20230912)
        ---------------------------------------------------------------
		select col_kodawari into kodawari from keplersc.kdms where c1=sucursal_id;
		
		if kodawari = 'S' then 
	
	        strValor := '';
	        strValor := (xpath('//row/c85/text()', xmlKDMM))[1];
	        if upper(strValor) = 'S' and upper(uen) = 'REF' then
	            paso:= 'docdis_xa.alta_backorder';
	            select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_backorder(dataxml,folio_operacion);
	            if get_resultado = '0' then
	                raise exception '%',get_mensaje;
	            end if;
	        end if;
       
	     end if;
       
		---------------------------------------------------------------
		--CONTABILIDAD. ALTA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
			if (xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' then --Pantalla c/movtos contables
				paso:= 'docdis.alta_cont_cont';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_cont(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			else
			
				-- Added by JMM 20241015 ... As Validation for Internal Docs
				if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO','CXP_DEPOSITO_INTERNO','CXP_DEPOSITO_INTERNO_BAJA','CXP_CONTR_REC_INTERNO_BAJA') then
				
					raise exception '%','La opcion contable [cont_general_alta]  No esta permitida para los Documentos Internos' || ' | ' || ' ' || ' | ' || 'Parametro C47 en KDMM';
				
				else
		
					-- Original Code (marked up) by JMM 20241015
					if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
						--MSS 25072025 Agregar el llamado a la funcion alta_cont_mov  CONTLIB.ALTA_CONT_MOV
						paso:= 'docdis_xd.alta_cont_mov';
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_mov(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;
					else
						paso:= 'docdis.cont_general_alta';
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
						strResumen:=strResumen || get_adicionales;				
					end if;	
				
				end if; -- IF ... ELSE / INTERNAL DOCs Added by JMM 20241015
			
			end if;
		end if;	
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		---------------------------------------------------------------					
			
	end if;

	--For Testing ... by JMM 20240423 
--raise exception '%', 'Error inyectado docdis_xa ...';
	
	get_resultado:=1;
	get_mensaje:=folio_operacion;
	get_adicionales:=strResumen;
	return query select get_resultado, get_mensaje, get_adicionales;

END;
$function$
