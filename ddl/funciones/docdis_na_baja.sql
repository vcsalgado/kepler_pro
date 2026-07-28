CREATE OR REPLACE FUNCTION keplersc.docdis_na_baja(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos N, A (No Genero, Acreedores) baja
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Luis Leal
	--Fecha: 12 Octubre 2022
	
	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	uen text;


	--xml Movimiento
	xmlKDM1 xml;

	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;

	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;
	cmmnt text;
		
	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	

begin
	-- Inicializacion de variables
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



	if genero = 'N' and naturaleza = 'A' then --No genero, Acreedora
		---------------------------------------------------------------
			
		--MOVIMIENTOS. Registro de movimiento en kdm1.
		--Resuelve: BAJA_MOV_PRIM 
		---------------------------------------------------------------
		paso:= 'docdis.mov_prim_baja';
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_baja(dataxml, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
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
		--DETALLE MOVIMIENTOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
		--LGLG 31/05/24 , solo si no es vale de salida
		if grupo <> '13' then 
	
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

		end if;
	
		--//TODO, Baja inventarios
	
		/*if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --Afecta Inventarios
			((xpath('//row/c52/text()', xmlKDMM))[1]::text is null or (xpath('//row/c52/text()', xmlKDMM))[1]::text <> 'S')  and --Maneja Backorder
			((xpath('//row/c83/text()', xmlKDMM))[1]::text is null or (xpath('//row/c83/text()', xmlKDMM))[1]::text <> 'S') and --Backorder
			((xpath('//row/c84/text()', xmlKDMM))[1]::text is null or (xpath('//row/c84/text()', xmlKDMM))[1]::text <> 'S')  --Abrir campo Importe TO DO: Verifcar desino del campo  
			then
				paso:= 'docdis.invr_movtos_alta';
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_movtos_alta(dataxml,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;	
		end if;*/
	
	
		--Pago Operarios, Registro de movimiento en kdhorpag, kdtablanom
		---------------------------------------------------------------
		if genero = 'N' and naturaleza = 'A' and grupo = '19' and tipo = '1' then 
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.ser_baja_pago_ope(dataxml,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
		end if;
	

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
	
	
		cmmnt = coalesce((xpath('//document/k_coment/text()',dataxml))[1]::text,'')::text ;

		---------------------------------------------------------------
		--AJUSTE DIFERENCIAS. Ajusta diferencias inventario fisico.
		--Resuelve: ALTA_INVR_FISICO---------------------------------------------------------------
		if  ( genero = 'N' and naturaleza = 'A' and grupo = '30' ) and uen ='REF' and cmmnt = 'Ajuste de Refacciones' then 
			paso:= 'docdis.invr_fisico_ajuste_sumas';	
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.invr_fisico_ajuste(dataxml, folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
	
	
	end if;
--raise exception 'ERROR INYECTADO 1';
	get_resultado:=1;
	get_mensaje:=folio_operacion;
	return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
