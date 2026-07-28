CREATE OR REPLACE FUNCTION keplersc.docdis_na(dataxml xml, xmlkdmm xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos N, A (No Genero, Acreedores)
	--Debe ser llamada desde docdis, donde se calculan los parametros dataXml y xmlKDMM)
	--Esta funcion se considera una extension de docdis y no puede ser llamada de forma
	--aislada.
	--Autor: Victor Salgado
	--Fecha: 27 Junio 2022
	--13/03/2025 Victor Salgado: Se elimina validacions para obetncion de folio
	
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
	strResumen text = '';

	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;
	uen text= '';
	cmmnt text;

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

	if genero = 'N' and naturaleza = 'A' then --No genero, Acreedora
	
		---------------------------------------------------------------
		--Obtencion de consecutivo
		---------------------------------------------------------------
		--TO DO: Verificar con que variable se identifican documentos que registran movimiento	
		folio_id := (xpath('//row/c17/text()', xmlKDMM))[1] || '.' || sucursal_id; --Identificador del consecutivo del documento
		strValor := (xpath('//row/c93/text()', xmlKDMM))[1];
--		if strValor is null or strValor <> 'S' then
			--TO DO:Validar de donde se obtienen los adicionales c2 y c3, se estan mandando 0 y 0 por default, pero no es asi para todos
			paso := 'docdis.obtener_folio_documento';
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.obtener_folio_documento(folio_id,0,0, dataxml);			
			if get_resultado = '0' then	
				raise exception '%',get_mensaje;
			end if;
			folio_operacion := get_mensaje;
--		else
			--TO DO: Verificar, hasta el momento para esta condición no hay ningún documento
			--       ¿Como se procesan documentos donde no se les calcula el folio?
--		end if;		
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm1
		---------------------------------------------------------------
		paso:= 'docdis.mov_prim_alta';	
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.mov_prim_alta(dataxml, folio_operacion);
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;
		
		---------------------------------------------------------------
		--EDO BONIFICACION. Actualiza movimiento en kdm1
		---------------------------------------------------------------
		if uen ='VEN' and genero = 'N' and naturaleza = 'A' and grupo = '28' then 
			paso:= 'docdis.venedomovtobonif';	
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.venedomovtobonif(dataxml);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;
		---------------------------------------------------------------
		--INVENTARIOS. Registro de movimiento en kdm2
		---------------------------------------------------------------
		if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' or 
			(xpath('//row/c83/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c84/text()', xmlKDMM))[1]::text = 'S' or
			(xpath('//row/c85/text()', xmlKDMM))[1]::text = 'S' then
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
		--Obtener xml de KDM1 de registro generado 		
		expSql = 'select * from keplersc.kdm1 where' || 
			' c1=' || E'\'' || sucursal_id || E'\'' ||  
			' and c2=' || E'\'' || genero || E'\'' ||
			' and c3=' || E'\'' || naturaleza || E'\'' || 
			' and c4=' || grupo || 
			' and c5=' || tipo ||
		  	' and c6=' || E'\'' || folio_operacion || E'\'';
		
		select query_to_xml(expSql, true, false, '') into xmlKDM1;
		
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
		end if;
		
		---------------------------------------------------------------
		--INI INVENTARIOS : ALTA_INVENT
		---------------------------------------------------------------	
		------ Seccion agregada por Saltiel Cruz
			paso :=(xpath('//row/c65/text()', xmlKDMM))[1]::text ;--Estado operacion inventario
			if (xpath('//row/c8/text()', xmlKDMM))[1]::text = 'S' and --S=Afecta Inventarios
				paso::int > 0  then
				paso:= 'docdis.invlib_ALTA_INVENT';					
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_alta_invent(dataxml,xmlKDMM,folio_operacion);
				if get_resultado = '0' then
					raise exception '%',get_mensaje;
				end if;
				/*paso:= 'docdis.invlib_INV_ALTA_NOTA_CREDITO';					
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.invlib_inv_alta_nota_credito(dataxml,xmlKDMM,folio_operacion);
					if get_resultado = '0' then
						raise exception '%',get_mensaje;
					end if;*/
			end if;
		---------------------------------------------------------------
		--FIN INVENTARIOS : ALTA_INVENT.
		---------------------------------------------------------------				
		raise notice 'fin_alta_invent';
	
	
		---------------------------------------------------------------
        -- REFACCIONES : ALTA_BACKORDER (Added by JMM 20230910)
        ---------------------------------------------------------------
        strValor := '';
        strValor := (xpath('//row/c85/text()', xmlKDMM))[1];
        if upper(strValor) = 'S' and upper(uen) = 'REF' then
            paso:= 'docdis_nd.alta_backorder';
            select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_backorder(dataxml,folio_operacion);
            if get_resultado = '0' then
                raise exception '%',get_mensaje;
            end if;
        end if;	
	
		---------------------------------------------------------------
		--CONTABILIDAD. ALTA_CONT
		---------------------------------------------------------------
		if (xpath('//row/c6/text()', xmlKDMM))[1]::text = 'S' then --Afecta contabilidad
			if (xpath('//row/c71/text()', xmlKDMM))[1]::text = 'S' then --Pantalla c/movtos contables
				--TO DO: Desarrollar CONTLIB.ALTA_CONT_CONT
			else
				if (xpath('//row/c47/text()', xmlKDMM))[1]::text = 'S' then --Pantalla movimientos CXP
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
					strResumen:=strResumen || '|' || get_adicionales;				
				end if;					
			end if;
		end if;
		---------------------------------------------------------------
		--FIN CONTABILIDAD.
		----------------------------------------------------------------
	
		---------------------------------------------------------------
		--BONIFICACION. Registro de bonificación en kdbonif.
		--Resuelve: ALTA_BONIF 
		---------------------------------------------------------------
		if uen = 'VEN' and ((xpath('//row/c66/text()', xmlKDMM))[1]::text = 'C' or (xpath('//row/c66/text()', xmlKDMM))[1]::text = 'V') then  
			paso := 'docdis.alta_bonif';	
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.alta_bonif(dataxml,xmlkdmm,xmlkdm1,folio_operacion);
			if get_resultado = '0' then
				raise exception '%',get_mensaje;
			end if;
		end if;

	
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
	get_adicionales:=strResumen;
	return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
