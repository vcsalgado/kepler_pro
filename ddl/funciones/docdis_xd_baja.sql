CREATE OR REPLACE FUNCTION keplersc.docdis_xd_baja(dataxml xml, xmlkdmm xml)
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
	
	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;

	--xml Movimiento
	xmlKDM1 xml;


	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;

	valida_devoluciones int;

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

	folio_operacion := (xpath('//document/k_folio/text()', dataxml))[1];


/*
 * CUENTAS POR PAGAR Genero 'X'
*/

	valida_devoluciones := 0;

	if genero = 'X' and naturaleza = 'D' then --Cuentas por pagar, Acredora	
	
		-- Analizar si Aplica esta Validacion o No por que es (Entrada al INV) y por la programacion
		-- De esta opcion en K75; Por lo pronto se comenta ...
		/*
		if grupo = '40' and tipo = '1' then
			valida_devoluciones = 1;
		end if;
		*/
		if grupo <> '31' and grupo <> '33' and grupo <> '36' then
			-- VALIDAR TOTALES Y DATOS GENERALES DE DOCTOS  ... PARA CUALQUIER X_D 
			paso:= 'docdis_xd.valida_operacion_documentos';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.valida_operacion_documentos(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		end if;
	
		-- Analizar si Aplica esta Validacion o No por que es (Entrada al INV) y por la programacion
		-- De esta opcion en K75; Por lo pronto se comenta ...
		/*
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
		*/
	
	
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		--VCSS: Verificar el uso de variable folio_id ya que folio_operacion se inicia con el xml.
		if grupo = '40' then 
			if tipo = '1' then 

					-- * * * Para estas opciones no aplica la funcion de obtencion de Folio ..
			
					get_mensaje := ' , Por Procesar ... Opcion en Construccion ...';
					folio_operacion := folio_id || get_mensaje;
				
					--cmnt(1).free4eg by JMM
					raise exception '%',folio_operacion;
								
	   
			end if; -- * * * Tipo 1 
			
		end if; -- * * * Grupo 40
		
		---
		-- FIN Consecutivo
		---
		
		--/* START cmnt by JMM ...
		
		
		--Validar que la cxp se pueda dar de baja
		if (xpath('//row/c47/text()', xmlKDMM))[1]::text  <> 'S'			--Pantalla de movtos de cxp
			and (xpath('//row/c7/text()', xmlKDMM))[1]::text = 'S' then		--Afecta cxcp
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.verify_cxcp_baja(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
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
		--Cuentas por Cobara y/o Pagar, ejecuta:
		--k75:CXCPLIB.CXCPLIB.BAJA_CXCP 	Resuelve bajas de CXCP_ALTA_SINMOV
		---------------------------------------------------------------
		if (xpath('//row/c7/text()', xmlKDMM))[1]::text  = 'S' then --Afecta Cuentas por Cobrar o Pagar
			
			if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
			
				paso:= 'docdis.cxcp_baja_conmov';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.cxcp_baja_conmov(dataxml, xmlKDMM, folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
			
			else
				
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
					
			end if;
		
					

		end if;
	
	
		--FIN CXCP_ALTA_CONMOV
		---------------------------------------------------------------		
		--FIN CxCP
		---------------------------------------------------------------

---------------------------------------------------------------
		--CONTABILIDAD. BAJA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
			paso:= 'docdis.cont_general_baja';

			select * into get_resultado, get_mensaje, get_adicionales from keplersc.cont_general_baja(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;	
		end if;	
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		---------------------------------------------------------------		
	end if; ---*** Genero, Naturaleza

--raise exception '%',folio_operacion;
	get_resultado:='1';
	get_mensaje:=folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;

END;
$function$
