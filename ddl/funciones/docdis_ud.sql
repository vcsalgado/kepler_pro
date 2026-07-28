CREATE OR REPLACE FUNCTION keplersc.docdis_ud(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos U, D (Cuentas por Cobrar, Deudoras)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Victor Salgado
	--Fecha: 27 Junio 2022
--Bitacora de cambios
--22/12/2024 Miriam Santana: Se incluye validaciones para anulacion de cobros
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

	flag_cobros text = '';	--MSS 22122024 Anulacion de cobro
		
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

	flag_cobros :=coalesce((xpath('//document/ambiente/flag_cobros/text()',dataxml))[1]::text,'')::text;		--MSS 22122024 Anulacion de cobro

	if genero = 'U' and naturaleza = 'D' then --Cuentas por cobrar, Deudora			
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
		--Validacion Refacciones
		---------------------------------------------------------------
	    if uen = 'REF' then
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_altainvr(dataxml);
	        if get_resultado = '0' then
	             raise exception '%',get_mensaje;
	        end if;
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
		--Validacion de la Nota de Credito Y Anulacion
		---------------------------------------------------------------
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_nota_credito_anulacion(dataxml, xmlkdmm);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	
		    
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento		
		strValor := (xpath('//row/c93/text()', xmlKDMM))[1];
		
		if (xpath('//row/folio_manual/text()', xmlKDMM))[1]::text = 'S' then		--MSS 16102024 Folio manual
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_folio_manual(dataxml);	
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
			folio_operacion := get_mensaje;

		else
--			if strValor is null or strValor <> 'S' then		--Valida c93
				--TO DO:Validar de donde se obtienen los adicionales c2 y c3, se estan mandando 0 y 0 por default, pero no es asi para todos
				paso := 'docdis.obtener_folio_documento';
		
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0,dataxml);
				
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				folio_operacion := get_mensaje;
--			end if;
		end if;

		---------------------------------------------------------------
		--MOVIMIENTOS. Registro de movimiento en kdm1.
		--Resuelve: ALTA_MOV_PRIM_SFOLIO 
		---------------------------------------------------------------
		paso:= 'docdis.mov_prim_alta';
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_alta(dataxml, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;

	
		--N.Credito y Anulacion Nota de descuento
		if (genero='U' and naturaleza ='D' and grupo='61' and tipo='1') or
			(genero='U' and naturaleza ='D' and grupo='63' and tipo='1') then 	
			update keplersc.kdm1 set c43='C' where c1=sucursal_id and c2=genero and c3='A' and c4=52 and c5=tipo::numeric and c6=(xpath('//document/k_refer/text()', dataxml))[1]::text;
		end if;
	
		--N.Credito y Anulacion Subsidio 
		if (genero='U' and naturaleza ='D' and grupo='62' and tipo='1') or 
			(genero='U' and naturaleza ='D' and grupo='65' and tipo='1') then 	
			update keplersc.kdm1 set c43='C' where c1=sucursal_id and c2=genero and c3='A' and c4=53 and c5=tipo::numeric and c6=(xpath('//document/k_refer/text()', dataxml))[1]::text;
		end if;
		---------------------------------------------------------------
		--Registro de ?ltimo movimiento del cliente en kdud
		--Resuelve: REGISTRA_ULTIMO_MOVIMIENTO_CLIENTE
		---------------------------------------------------------------
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.reg_ult_movto_cte(dataxml, xmlKDMM);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
	
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
	
		--raise exception '%, %' , xpath('//row/c8/text()', xmlKDMM) , xpath('//row/c86/text()', xmlKDMM);
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
			end if;	
		end if;

		if uen = 'REF' then
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or
				(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
				(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
				(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S'  then
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
	
		if uen = 'VEN' or uen = 'XXX' then
			if (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'C' then
				
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
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' then
				
				paso:= 'docdis.mov_sec_alta';
				
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_alta(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
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
			--CXCP_SUSTITUCION			
			if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S'  --Gen CFD
				and (xpath('//row/c86/text()', xmlKDMM))[1]::text = 'S' then --Abrir campo Importe
				--TO DO: Desarrollar CXPLIB.CXCP_SUSTITUCION				
			end if; --FIN CXCP_SUSTITUCION

			--MSS 14042026 Validacion si cartera debe ser PPD			
			if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then
				if (xpath('//row/c162/text()', xmlKDM1))[1]::text = 'PUE' then
--					raise exception 'El movimiento genera cartera, el metodo de pago no puede ser PUE, cambielo a PPD';
				end if;			
			end if;
			
			--CXCP_ALTA_SINMOV
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text <> 'S' then --Pantalla movimientos CXP			
				--CXCP_ALTA_SINMOV
				paso:= 'docdis.cxcp_sinmov_kduxe_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxe_alta(dataxml, xmlKDMM, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;					
			
				paso:= 'docdis.cxcp_sinmov_kduxg_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_sinmov_kduxg_alta(dataxml,get_adicionales::xml, folio_operacion);
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
		--INVENTARIOS
		---------------------------------------------------------------
	
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --Afecta Inventarios
			((xpath('//row/c52/text()', xmlKDMM))[1]::text is null or (xpath('//row/c52/text()', xmlKDMM))[1]::text <> 'S')  and --Maneja Backorder
			((xpath('//row/c83/text()', xmlKDMM))[1]::text is null or (xpath('//row/c83/text()', xmlKDMM))[1]::text <> 'S') and --Backorder
			((xpath('//row/c84/text()', xmlKDMM))[1]::text is null or (xpath('//row/c84/text()', xmlKDMM))[1]::text <> 'S')  --Abrir campo Importe TO DO: Verifcar desino del campo  
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
			
			
				if (xpath('//row/c65/text()', xmlKDMM))[1]::text = '80' 
				then
					paso:= 'docdis.invlib_ALTA_TRASPASO';
					 
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

		end if;
	
		--INSERT KDREF
		/*if genero = 'U' and naturaleza = 'D' and grupo = '7' and tipo='1' and uen='REF' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.carga_refacciones_insert(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;*/
		---------------------------------------------------------------
		--FIN INVENTARIOS
		---------------------------------------------------------------	

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
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP

					if flag_cobros = 'ANULACION_COB' then		--MSS 22122024 Anulacion de cobro
						paso:= 'docdis_ud.alta_cont_mov';
						select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_cont_mov(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
						if get_resultado = '0' then
							raise exception '%',get_mensaje;
						end if;
					else 
						--CALL ALTA_CONT_MOV
					end if;	
				else 
				
				--CALL ALTA_CONT_GENERAL
					paso:= 'docdis.cont_general_alta';			
					select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_alta(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
					if get_resultado = '0' then	
						raise exception '%',get_mensaje;
					end if;	
					strResumen:=strResumen || '|' || get_adicionales;				
				end if;--					
		end if;	
	
	--raise notice '%', 'Fin cont';
	--raise exception '%', 'Error inyectado';
	---------------------------------------------------------------
	--FIN CONTABILIDAD.
	---------------------------------------------------------------		
	
		-- CARGA REFACCIONES EN KDREF
		if uen='REF' and grupo='7' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.carga_refacciones_insert(dataxml,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;

		---------------------------------------------------------------
		--Genera informaci?n y archivo para CFDI.
		--Resuelve:CFD_CREA_ARCHIVO
		---------------------------------------------------------------
		if (xpath('//row/c80/text()', xmlKDMM))[1]::text = 'S' then --Genera CFD
			if uen ='VEN' then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_anticipo(dataxml,xmlKDM1,xmlKDMM,folio_operacion);		--MSS 15032025 Enviar dataxml 
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			
			end if;
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cfd_crea_archivo(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		end if;		
	end if;

	get_resultado:=1;
	get_mensaje:=folio_operacion;
	get_adicionales:=strResumen;
	return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
