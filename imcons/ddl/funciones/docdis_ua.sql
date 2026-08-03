CREATE OR REPLACE FUNCTION keplersc.docdis_ua(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos U, A (Cuentas por Cobrar, Acreedoras)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Victor Salgado
	--Fecha: 27 Junio 2022
	--Bitacora de cambios
	--30/10/2024 Miriam Santana: Se incluye validaciones para anulacion de cobros, antes sustitucion
	--13/03/2025 Victor Salgado: Se elimina validacions para obetncion de folio
	--15/03/2025 Miriam Santana: Enviar el dataxml a CFD_ANTICIPO
	
	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	uen text = '';

	--xml Movimiento
	xmlKDM1 xml;


	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;
	strResumen text = '';

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

	if genero = 'U' and naturaleza = 'A' then --Cuentas por cobrar, Acredora			
	
		---------------------------------------------------------------
		--Validacion de la alta de cxp o cxc
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' then		--Afecta cxcp
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_cxcp_alta(dataxml,xmlkdmm);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
		
		---------------------------------------------------------------
		--Validacion de la Nota de Crédito Y Anulacion
		---------------------------------------------------------------
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_nota_credito_anulacion(dataxml, xmlkdmm);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;

		---------------------------------------------------------------
		--Validacion de la INV
		---------------------------------------------------------------
		if uen = 'VEN' then
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_invalta(dataxml);
	        if get_resultado = '0' then
	             raise exception '%',get_mensaje;
	        end if;
	     end if;
	    
	    
	    ---------------------------------------------------------------
		--Validacion Refacciones
		---------------------------------------------------------------
	    if uen = 'REF' then
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_altainvr(dataxml);
	        if get_resultado = '0' then
	             raise exception '%',get_mensaje;
	        end if;
	     end if;
	    
	 
	    
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento		
--		if strValor is null or strValor <> 'S' then		--Valida c93	
			--TO DO:Validar de donde se obtienen los adicionales c2 y c3, se estan mandando 0 y 0 por default, pero no es asi para todos
			paso := 'docdis.obtener_folio_documento';
	
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0,dataxml);
			
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_operacion := get_mensaje;			
			/*if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then		--Valida c80
				--Resuelve CFD_GENERA_FOLIO Y CDF_GUARDA_FOLIO
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_genera_folio(folio_operacion, sucursal_id, genero, naturaleza, grupo, tipo);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_operacion := get_mensaje;
			else 
				strValor := right(folio_operacion,5);
				folio_operacion := concat('00',strValor);
			end if;	
		*/
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
	
		---------------------------------------------------------------
		--Registro de movimiento en kdm2
		---------------------------------------------------------------

		if uen = 'REF' then
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or 
				(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
				(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
				(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S'  then
				paso:= 'docdis.mov_sec_alta';
			
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
			else
			
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S'  then
					paso:= 'docdis.alta_doc_sec';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_doc_sec(dataxml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;   					

				end if;	
			
			end if;	
		
		
		end if;

	
		if uen = 'VEN' or uen = 'XXX' then
			if ((xpath('//row/c86/text()', xmlKDMM))[1]::text = 'C') or 
			(genero='U' and naturaleza ='A' and grupo='5' and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'O' )  then --Validacion especial para anulacion de nota de cargo
				
				paso:= 'docdis.mov_sec_alta';
				
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
			else

				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S'  then
					paso:= 'docdis.alta_doc_sec';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_doc_sec(dataxml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;   
				end if;	
			
			end if;
		
		end if;
	

		if uen = 'SER' then
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or  (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'C' then
				
				paso:= 'docdis.mov_sec_alta';
				
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
			else
			
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S'  then
					paso:= 'docdis.alta_doc_sec';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_doc_sec(dataxml, folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;   
				end if;	
		
			end if;
		
		end if;
	

		--Obtener xml de KDM1 de registro generado 		
		expSql = 'select * from keplersc.kdm1 where' || 
			' c1=' || E'\'' || sucursal_id || E'\'' ||  
			' and c2=' || E'\'' || genero || E'\'' ||
			' and c3=' || E'\'' || naturaleza || E'\'' || 
			' and c4=' || grupo || 
			' and c5=' || tipo ||
		  	' and c6=' || E'\'' || folio_operacion || E'\'';

		select query_to_xml(expSql, true, false, '') into xmlKDM1;
	
			---------------------------------------------------------------
		--Registro de la orden
		--Resuelve: ALTA_ORDEN y ejecuta: ALTA_ORDEN_FACTURA,ALTA_ORDEN_NOTA_CREDITO,ALTA_ORDEN_VEN_TALL,
		--								  ORD_GUARDA_COSTO_INVENTARIO, ORDEN_ALTA_NOTA 
		---------------------------------------------------------------
		if uen='SER' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.ser_alta_orden(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
	
		---------------------------------------------------------------
		--Cuentas por Cobrar y/o Pagar CXCPLIB.ALTA_CxCP, ejecuta:
		--k75:CXCPLIB.ALTA_CXCP.CXCP_SUSTITUCION
		--k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_SINMOV
		--k75:CXCPLIB.ALTA_CXCP.CXCP_ALTA_CONMOV		
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' then --Afecta Cuentas por Cobrar o Pagar		
			--MSS 30102024 YA NO EXISTE LA SIG CONFIG PARA SUSTITUCIONES, AHORA SERAN ANULACIONES Y PASARAN POR CXCP_ALTA_CONMOV
			--CXCP_SUSTITUCION
			/*		
			if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S'  --Gen CFD
				and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'S' then --Abrir campo Importe

				select * into get_resultado, get_mensaje, get_adicionales from  keplersc.cxcp_sustitucion_kduxg_baja(dataxml, xmlkdmm);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;			
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sustitucion_kduxe_baja(dataxml, xmlkdmm);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;							
			end if; --FIN CXCP_SUSTITUCION
			*/

			--CXCP_ALTA_SINMOV
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text <> 'S' then --Pantalla movimientos CXP			
				--CXCP_ALTA_SINMOV
				paso:= 'docdis.cxcp_sinmov_kduxe_alta';
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
		end if;
		---------------------------------------------------------------		
		--FIN CxCP
		---------------------------------------------------------------
	
	
		---------------------------------------------------------------
		--Registro de alta de caja
		--Resuelve: ALTA_CAJA
		---------------------------------------------------------------
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.caja_alta(dataxml, xmlKDMM, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
	
		---------------------------------------------------------------
		--INVENTARIOS  Saltiel RC 06/Dic/2022
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
	
	
	
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and uen = 'VEN'  --Afecta Inventarios	y se personaliza  
			-- Added by JMM 20230107 
			and coalesce((xpath('//row/c65/text()', xmlKDMM))[1]::text,'0')::numeric > 0 
		then
			
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '20'--CALL INV_PEDIDO_ALTA  
				then
					paso:= 'docdis.invlib_inv_pedido_alta';			
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_inv_pedido_alta(dataxml,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
				end if;
			
				if (xpath('//row/c67/text()', xmlKDMM))[1]::text = 'S' and 
		     		(xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' 
					then
						if uen = 'VEN' then
							paso:= 'docdis.Cargo/Abonos-PedidoExtras';
							select * into get_resultado, get_mensaje, get_adicionales from keplersc.altapedido_pedidoextras(dataxml,folio_operacion);
							if get_resultado = '0' then
								raise exception '%',get_mensaje;
							end if;
						end if;
				end if;	 
				
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '30'--CALL FACTURA DEL AUTOMOVIL  
				then
					paso:= 'docdis.invlib_ALTA_INVENT';
					 
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_alta_invent(dataxml,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
				end if;
		

				-- Condition included by JMM 20230108 , based on Docdis_UD 
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '80' then
				
					paso:= 'docdis.invlib_BAJA_TRASPASO';
					 
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_traspaso(dataxml,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
					
				end if;
			
			
			
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '90' 
				then
					paso:= 'docdis.invlib_FACTURA_PVA';
					 
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_factura_pva(dataxml,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;	
				end if;
			
					
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '95'--CALL NOTA DE DESCUENTO 
				then
					paso:= 'docdis.invlib_ALTA_NOTA_DESCUENTO';
					 
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_alta_nota_descuento(dataxml,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				end if;
			
			
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '96'--CALL SUBSIDIO
				then
					paso:= 'docdis.invlib_ALTA_SUBSIDIO';
									 
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_alta_subsidio(dataxml,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;	
				end if;
			
				---------------------------------------------------------------
				--FIN INVENTARIOS
				---------------------------------------------------------------	
			
		end if;	
	
	
		-- CALL INV_ALTA_NOTA_CREDITO
		if uen <> 'SER' then
			paso:= 'docdis.ALTA_NOTA_CREDITO';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_nota_credito_anulacion(dataxml,xmlkdmm, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
	
		---------------------------------------------------------------
		--CONTABILIDAD. ALTA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
		
		
				if (xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
					
					paso:= 'docdis.alta_cont_cont';
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_cont(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;
		
				else
				
					if (xpath('//row/c10/text()', xmlKDMM))[1]::text = 'C' then 
					
						--  CALL ALTA_CONT_OCOMPRA
					else
					
						--MSS 30102024 Ya no sera Sutitucion ahora sera Anulacion c80='S' c47='S' c86='O' 
						--if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'S' then 
						if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' and (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'O' then
							paso:= 'docdis.sustituye_cont';
							select * into get_resultado, get_mensaje, get_adicionales from keplersc.sustituye_cont(dataxml,xmlKDMM,folio_operacion);
							if get_resultado = '0' then
								raise exception '%',get_mensaje;
							end if;
						
						else 
						
							if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
								paso:= 'docdis_xd.alta_cont_mov';
								select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_mov(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
								if get_resultado = '0' then
									raise exception '%',get_mensaje;
								end if;
							else 
							
								--CALL ALTA_CONT_GENERAL
								paso:= 'docdis.cont_general_alta'; --raise notice 'dataxml %',dataxml;raise notice 'xmlKDM1 %',xmlKDM1;raise notice 'xmlKDM1 %',xmlKDMM;raise notice 'folio_operacion %',folio_operacion;
								select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
								if get_resultado = '0' then	
									raise exception '%',get_mensaje;
								end if;	
								strResumen:=strResumen || '|' || get_adicionales;				
							end if;--

						end if;
					
					end if;
					
				
				end if;
					
		end if;	
	
		raise notice 'Paso:% %',paso,'Fin cont';
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		---------------------------------------------------------------		
		
		---------------------------------------------------------------
		--Genera información y archivo para CFDI.
		--Resuelve:CFD_CREA_ARCHIVO
		---------------------------------------------------------------
		if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then --Genera CFD
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_anticipo(dataxml,xmlKDM1,xmlKDMM,folio_operacion);		--MSS 15032025 Enviar dataxml
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_sustitucion(xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_crea_archivo(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;			
		end if;		
		---------------------------------------------------------------
		--FIN Genera información y archivo para CFDI.
		---------------------------------------------------------------		
							
	end if;

	get_resultado:=1;
	get_mensaje:=folio_operacion;
	get_adicionales:=strResumen;
	return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
