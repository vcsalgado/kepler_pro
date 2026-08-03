CREATE OR REPLACE FUNCTION keplersc.docdis_xa_baja(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa la baja de los tipos de documentos X, A (Cuentas por Pagar, Acreedoras)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Miriam Santana
	--Fecha: 19/08/2022

	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	referencia text = '';
	clave_cteprov text = '';
	uen text = '';

	--xml Movimiento
	xmlKDM1 xml;


	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;

	paso text;
	xmlResultado xml;
	folio_id text;
	
	--Added by JMM 20241017 (Ctrl Gastos CxP)
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
	folio_operacion := (xpath('//document/k_folio/text()', dataxml))[1];
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');

	if genero = 'X' and naturaleza = 'A' then --Cuentas por pagar, Acredora		
	
		--Added by JMM 20241017
		-- * * *  VALIDACION DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
		flag_gastos = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;
		
	
		--Added by JMM 20241017 (condition)  
		-- * * *  VALIDACION DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
		if upper(flag_gastos) in /*=*/ ('CXP_CONTR_REC_INTERNO_BAJA'/*, 'CXP_DEPOSITO_INTERNO_BAJA'*/) then 

			paso:= 'docdis_xd.gpogasto_validacion';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_validacion(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		
		else 
	
			--  * * *  EJECUTA TODAS LAS VALIDACIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241011
	
			-- VALIDAR TOTALES Y DATOS GENERALES DE DOCTOS  ... PARA CUALQUIER X_A
			-- Implemented by JMM ... 220726 
			if (grupo <> '55' and tipo <> '1') and (grupo <> '12')  then	--MSS: Lo siguiente no aplica para X A 55 1
				paso:= 'docdis_xa.valida_operacion_documentos';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_documentos(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			end if;
		
			--Validar que la cxp se pueda dar de baja
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text  <> 'S'			--Pantalla de movtos de cxp
				and (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' then		--Afecta cxcp
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_cxcp_baja(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
			end if;
		
		end if; --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241017
	
	
	
		--MSS: Para estos movimientos no se genera folio, es a partir del folio_operacion
		---------------------------------------------------------------
		--MOVIMIENTOS. Registro de movimiento en kdm1.
		--Resuelve: BAJA_MOV_PRIM 
		---------------------------------------------------------------
		
			paso:= 'docdis.mov_prim_baja';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_baja(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		
		---------------------------------------------------------------
		--DETALLE MOVIMIENTOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or 
			(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S' then
			paso:= 'docdis.mov_sec_baja';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_sec_baja(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
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
		--TOTs Registro de movimiento en kdtot
		---------------------------------------------------------------
		if genero = 'X' and naturaleza = 'A' and grupo = '55' and tipo = '1' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.ser_tots_crud(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;

		end if;
		---------------------------------------------------------------
		--Cuentas por Cobara y/o Pagar, ejecuta:
		--k75:CXCPLIB.CXCPLIB.BAJA_CXCP 	Resuelve bajas de CXCP_ALTA_SINMOV y CXCP_ALTA_CONMOV
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text  = 'S' then --Afecta Cuentas por Cobrar o Pagar
		
		
			-- Added by JMM 20241011 
			-- * * *  GESTION DE MONTOS DE GPOS DE GASTO ... PARA USO DE DOCUMENTOS INTERNOS 
			if upper(flag_gastos) in ('CXP_CONTR_REC_INTERNO_BAJA'/*,'CXP_CONTR_REC_INTERNO'*/) then
			
				paso:= 'docdis_xd.gpogasto_actualiza_montos';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.gpogasto_actualiza_montos(dataxml);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
			else 
			
				--  * * *  EJECUTA TODAS LAS FUNCIONES ORIGINALES PREVIOS A ESTA DOCUMENTACION , ADAPTED BY JMM 20241011
		
				paso:= 'docdis.cxcp_kduxg_baja';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_kduxg_baja(dataxml, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;			
				paso:= 'docdis.cxcp_kduxe_baja';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_kduxe_baja(dataxml, xmlKDMM, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
			end if; --  * * *  IF .. ELSE / FOR INTERNAL DOCUMENTs by JMM 20241017

		end if;
		---------------------------------------------------------------		
		--FIN CxCP
		---------------------------------------------------------------
	
		---------------------------------------------------------------
		--CONTABILIDAD. BAJA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
			paso:= 'docdis.cont_general_alta';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_baja(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		end if;	
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		---------------------------------------------------------------

			------------------------------------------------------------
		--INVR
		------------------------------------------------------------
		if uen = 'REF' then
			paso:= 'docdis.invr_baja';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_baja(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
		------------------------------------------------------------
		--FIN INVR
		------------------------------------------------------------
	end if;

	--For Testing ... 20241017 by JMM
	/*raise exception '%', 'La Transaccion se Procesara ... [BAJA]';*/

	get_resultado:=1;
	get_mensaje:=folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;

END;
$function$
