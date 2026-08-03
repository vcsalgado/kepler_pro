CREATE OR REPLACE FUNCTION keplersc.docdis(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
--Bitacora de cambios
--26/03/2025 Miriam Santana: Enviar el dato detalle_movto para registrarse en bitacora KDUSRACCESS
--02/09/2025 Miriam Santana: Ajustar poliza descuadrada por 0.01
DECLARE 
	--Variables para xml
	sucursal_desc text;
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	usuario_movto text;
	fecha_movto text;
	hora_movto text;
	operacion_desc text = '';
	
	--xml documento
	xmlKDMM xml;


	--xml Bitacora usuario
	xmlUsr xml;	

	--Variables de uso general
	mensajeError text;
	expSql text;
	totalReg int;
	strValor text;
	folio_operacion text;

	transaccion_id text;
	paso text;
	referencia text;
	xmlResultado xml;
	folio_id text;

	resultado_validaciones text;

	-- Var Added by JMM 221027, for funcs related to uen = AUT 
	uen text;

	--Variables de retorno desde funciones externas
	get_resultado text; --retorno
	get_mensaje text; --retorno
	get_adicionales text; --retorno
	
	--Variables de parametro o retorno hacia funciones externas
	put_resultado text; --retorno
	put_mensaje text; --retorno
	put_adicionales text; --retorno	
	
	-- Added by JMM 20240805
	flag_contrarec text;
	ref_compl text;
	rec1 record;

	detalle_movto text = '';		--MSS 26032025: Registro detalle de movimiento en bitacora
	
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
	operacion_desc := (xpath('//document/operacion/text()', dataxml))[1];

	--Movimiento
	usuario_movto := (xpath('//document/movimiento/usuario/text()',dataxml))[1];
	fecha_movto := (xpath('//document/movimiento/fecha/text()',dataxml))[1];
	hora_movto := (xpath('//document/movimiento/hora/text()',dataxml))[1];

	detalle_movto:= coalesce((xpath('//document/detalle_movto/text()', dataxml))[1]::text,'');			--MSS 26032025: Registro detalle de movimiento en bitacora

	--Definicion de variables para transaccion en general
	transaccion_id := keplersc.log_tran_id_gen(); --Obtiene identificador de la transaccion
	referencia := genero || '_' || naturaleza || '_' || grupo || '_' || tipo ;

	--Registro de INICIO de transaccion en bitacora


	call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, true, dataxml::text,'INFO',
		xmlResultado);

	/*
 	* Validaciones genericas del documento y obtencion del xml del documento
 	*/
	if genero is null or (genero<>'X' and genero<>'U' and genero<>'N') then
		mensajeError := 'Genero de documento no definido';
		raise exception '%: %',mensajeError,genero;
	end if;

	if naturaleza is null or (naturaleza<>'D' and naturaleza<>'A' and naturaleza<>'N') then
		mensajeError := 'Naturaleza de documento no definida';
		raise exception '%: %',mensajeError,naturaleza;
	end if;

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdmm where col_sucursal=sucursal_id and c1=genero and c2=naturaleza and c3=grupo::int and c4=tipo::int;
	
	if totalReg = 0 then
		mensajeError := 'Documento no definido en BD';
		raise exception '%',mensajeError;			
	end if;

	expSql = 'select * from keplersc.kdmm where col_sucursal='|| E'\'' || sucursal_id || E'\'' || ' and c1='  || E'\'' || genero || E'\'' ||
		' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;		
	select query_to_xml(expSql, true, false, '') into xmlKDMM;
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	if strValor is not null then
		if strValor = 'S' then
			mensajeError := 'Documento no valido';
			raise exception '%',mensajeError;			
		end if;
	end if;

	/*
	 * Validaciones genericas del documento y obtencion del xml del documento
 	*/
	select resultado_verificar into resultado_validaciones from keplersc.verifications(dataxml,xmlKDMM);

	/* 	
	 * FIN Validaciones genericas del documento y obtencion del xml del documento
 	*/


	if genero = 'X' then --Cuentas por pagar 	
		if naturaleza = 'A' then --Acreedora
			if upper(operacion_desc) = upper('baja') 

			then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_xa_baja(dataxml,xmlKDMM);
				--raise exception '%','Se Procesara como BAJA';
			else
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_xa(dataxml,xmlKDMM);
				--raise exception '%','Se Procesara como ALTA';
			end if;		
		end if; --Fin Naturaleza Acreedora

		if naturaleza = 'D' then --Naturaleza Deudora
		
			-- UPD by JMM 22118, porque las Operaciones de UEN = AUT & GPO = 6, 7 si generan folios en Operaciones = BAJA
			if upper(operacion_desc) = upper('baja') 
			and (
				(upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) <> 'VEN') or 
				(upper((xpath('//document/ambiente/uen/text()', dataxml))[1]::text) = 'VEN' and grupo <> '6' and grupo <> '7') 
			) 
			then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_xd_baja(dataxml,xmlKDMM);
				--raise exception '%','Se Procesara como BAJA';
			else
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_xd(dataxml,xmlKDMM);
				--raise exception '%','Se Procesara como ALTA';
			end if;		

		end if; -- * * * Naturaleza Deudora	
	end if;


	if genero = 'U' then --Cuentas por cobrar
		if naturaleza = 'A' then --Acreedora
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_ua(dataxml,xmlKDMM);
		end if;
	
		if naturaleza = 'D' then --Deudora
			select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_ud(dataxml,xmlKDMM);
		end if;
	end if;


	if genero = 'N' then --No Aplica Genero
	
		if naturaleza = 'A' then--Acreedora
			if upper(operacion_desc) = upper('baja') then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_na_baja(dataxml,xmlKDMM);
			else
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_na(dataxml,xmlKDMM);
			end if;
		end if;
	
		if naturaleza = 'D' then --Deudora
			if upper(operacion_desc) = upper('baja') then
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_nd_baja(dataxml,xmlKDMM);
			else
				select * into get_resultado, get_mensaje, get_adicionales from keplersc.docdis_nd(dataxml,xmlKDMM);
			end if;
		end if;
	end if;

	--Folio de la operacion
	put_resultado:=get_resultado;
	put_mensaje:=get_mensaje;
	folio_operacion:=get_mensaje;
	put_adicionales:=get_adicionales;

	--MSS 02092025 Ajusta poliza contable con registro en bitacora
	select * into get_resultado, get_mensaje, get_adicionales  from keplersc.cont_ajusta_poliza(dataxml,xmlKDMM,folio_operacion);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	else
		detalle_movto := get_adicionales;
		put_resultado='1';
	raise notice 'Detalle movto: %',detalle_movto;
	end if;	

	/*
 	* REGISTRO DE OPERACION EN BITACORA DE USUARIOS PARA TRANSACCIONES SATISFACTORIAS
 	*/
	
	fecha_movto :=  current_date::text;
	hora_movto := left(current_time::text, 8);

	if put_resultado='1' then
	
	
		--Added by JMM 20240805 ... Apply For SCH 'CXP_CONTR_REC' 
		flag_contrarec = '';
		if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
			flag_contrarec := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
		end if;
		
		--if upper(flag_contrarec) = 'CXP_CONTR_REC' or upper(flag_contrarec) = 'CXP_CONTR_REC_DEVCLI' /*Or ... Added by JMM 20240813*/ then 
		--Adapted by JMM 20241016
		if upper(flag_contrarec) in /*=*/ ('CXP_CONTR_REC','CXP_CONTR_REC_DEVCLI','CXP_CONTR_REC_INTERNO','CXP_CONTR_REC_INTERNO_BAJA') then  
		
			ref_compl := '';
			
			select w.* into rec1 from keplersc.kdm1 w 
			where w.c1 = sucursal_id and w.c2 = genero/*'X'*/  and w.c3 = naturaleza/*'A'*/ and w.c4 = grupo::integer and w.c5 = tipo::integer  
				and w.c6 = folio_operacion;
			
			if not found then 
				mensaje := 'No se encontro registro en KDM1 de la CxP de Origen ... ' || factura/*rec.c14*/;
				raise exception '%',mensaje;
			else
				mensaje := '';
				-- For Testing, It Continuing ...
				-- raise exception '%''%',rec1.c11,rec1.doc_refer_compl;
			end if;
		
			if length( coalesce(rec1.c11,'') ) > 0 then
				ref_compl := '[R] ' || rec1.c11 || ' | ';
			end if;
			if length( coalesce(rec1.doc_refer_compl,'') ) > 0 then
				ref_compl := ref_compl || '[C] ' || rec1.doc_refer_compl || ' | ';
			end if;
		
			if length( ref_compl ) > 0 then
				ref_compl := '[D] ' || rec1.c2 || rec1.c3 || rec1.c4 || rec1.c5 || rec1.c6 || ' | ' || ref_compl;
				-- For Testing, It Continuing ...
				-- raise exception 'ref_compl %', ref_compl;
			else
				raise exception '%', 'No se pudo determinar la Referencia de seguimiento para la Cuenta : ' || factura;
			end if;
		
			if upper(operacion_desc) in ('ALTA', 'BAJA') then
				if upper(flag_contrarec) = 'CXP_CONTR_REC_DEVCLI' then /*Condition Added by JMM 20240813*/
					operacion_desc := 'CONTR_REC_DEVCLI_' || upper(operacion_desc);
				else
					if upper(flag_contrarec) in /*=*/ ('CXP_CONTR_REC_INTERNO','CXP_CONTR_REC_INTERNO_BAJA') then /*Condition Added by JMM 20241016*/
						operacion_desc := 'CONTR_REC_INTERNO_' || upper(operacion_desc);
					else
						operacion_desc := 'CONTR_REC_' || upper(operacion_desc);
					end if;
				end if;
			end if;
			
			/*raise exception 'operacion_desc %', operacion_desc;*/
		
			select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
					   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
					   operacion_desc as tipo_movto , ref_compl as ref_compl/*Added by JMM 20240805*/ ) :: text into strValor;
		
		else 
	
			-- Code Added by JMM 221118 for funcs related to uen = AUT  
			uen := coalesce((xpath('//document/ambiente/uen/text()', dataxml))[1]::text,'');	
			uen := upper(trim(uen));
			if upper(uen) = upper('VEN') then 
				if (genero = 'X' and naturaleza = 'D' and grupo = '6')
					-- Added by JMM 230107 for funcs related to uen = VEN  
					or 
					(genero = 'U' and naturaleza = 'A' and grupo = '21')  			
				then 
				
					-- Code adapted for UEN = AUT & NAT D & GPO 6 by JMM 
					select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
					   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
					   'ALTA' as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;				--MSS 26032025: Registro detalle de movimiento en bitacora
				else
					-- Codigo Original DocDis 221118_2320
					select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
					   sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
					   operacion_desc as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;		--MSS 26032025: Registro detalle de movimiento en bitacora
					  
				end if;
			else 
				-- Codigo Original DocDis 221118_2320
				select xmlforest(usuario_movto as usuario, fecha_movto as fecha, hora_movto as hora, 
				sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
				operacion_desc as tipo_movto, detalle_movto as detalle_movto) :: text into strValor;			--MSS 26032025: Registro detalle de movimiento en bitacora		
			end if;
	
		end if;  /* Not SCH 'CXP_CONTR_REC' */ 
		
		
		select '<document>'||strValor||'</document>' into strValor;
		xmlUsr := strValor::xml;
		
		select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
		--raise notice '%',sucursal_id;	
		if get_resultado = '0' then
			raise exception '%',get_mensaje;
		end if;	
	end if;
 /*
 * FIN REGISTRO DE OPERACION EN BITACORA DE USUARIOS
 */
--raise exception 'TERMINADO...MANUAL';

	get_resultado := put_resultado;
	get_mensaje := folio_operacion;
	get_adicionales := put_adicionales;

	return query select get_resultado, get_mensaje, get_adicionales;

EXCEPTION
	WHEN others then	
		xmlResultado := '';
		call keplersc.log_transac_insert(transaccion_id, usuario_movto, referencia, paso, false, SQLERRM, 'ERR', xmlResultado);
		get_resultado := '0';
		get_mensaje := SQLERRM;
		get_adicionales := 'funcion docdis';
		return query select get_resultado, get_mensaje, get_adicionales;
END;
$function$
