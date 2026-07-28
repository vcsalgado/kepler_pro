CREATE OR REPLACE FUNCTION keplersc.doc_gastos_comprobar_rollback(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos X, A Convertidos o Comprobados (Cuentas por Pagar por Des-Comprobar)
	--No pasara por docdis, no se creara Docmento en KDM1 ni Cuenta por Pagar KDUXG, KDUXE 
	--pero estas Tablas seran Actualizadas Removiendo los Datos del XML asociado en la Operacion 
	--Esta Funcion solo es Accesible en el Modulo de Gastos 
	--Autor: Jose Mendoza 
	--Fecha: 13 Mayo 2024 al 14 Mayo 2024 
	
	--Variables para xml
	sucursal_id text;
	tipo_desc text;
	genero text;
	naturaleza text;
	grupo text;
	tipo text;
	tipo_clave text;
	uen text = '';

	referencia text = '';
	refanterior text = '';
	proveedor text = '';
	fecha_operacion text;
	iva numeric = 0;	
	monto numeric = 0;	
	subtotal numeric = 0;
	iva_factor numeric = 0;
	strMonto text = '';

	--Added by JMm 20240525 
	iva_ciclo numeric = 0;

	serie_uuid text = '';
	folio_uuid text = '';
	total_uuid text = '';
	fechatimbrado_uuid text = '';
	impuesto_uuid text = '';

	rec1 record;
	recg record;
	rece record;

	--Added by JMM 20240514 
	rec5 record;

	--Added by JMM 20240724 
	rect record;

	--Added by JMM 20240725 
	counter numeric = 0;

	--xml Movimiento
	xmlKDM1 xml;
	xmlKDMM xml; -- to get base on document of dataxml

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
	xmlResultado xml;
	folio_id text;

	flag_gastos text = '';
		
	--Variables de retorno desde funciones externas
	resultado text; --retorno
	mensaje text; --retorno
	adicionales text; --retorno
	
	--Added by JMM 20240429
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';
	operacion_desc text = '';
	xmlUsr xml;	
	docto text = '';
	hora_movto text = '';
	usuario_movto text = '';

	--Added by JMM 20240513 
	monto_k numeric = 0;
	
	--Added by JMM 20240805
	ref_compl text = '';

begin
	-- Inicializacion de variables
	folio_operacion := 0;
	resultado := '';
	adicionales := '';

	--Documento
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r5/text()', dataxml))[1];	
	uen := coalesce((xpath('//document/ambiente/uen/text()',dataxml))[1],'');

	operacion_desc := coalesce((xpath('//document/operacion/text()', dataxml))[1],''); /*Added by JMM 20240429*/

	-- Adapted ny JMM 20240514
	/*fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;*/
	fecha_operacion := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	strMonto := coalesce((xpath('//document/k_iva/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	iva := strMonto::decimal;
	strMonto := coalesce((xpath('//document/c_monto/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	monto := strMonto::decimal;

	--Added by JMM 20240513
	strMonto := coalesce((xpath('//document/k_monto/text()', dataxml))[1]::text,'0.00')::text; 
	monto_k := strMonto::decimal;

	subtotal := monto - iva;

	if monto <= 0 then
		mensajeError := 'El Monto de la Operacion No puede ser menor o igual a cero ...';
		raise exception '%',mensajeError;
	end if;

	--Added by JMM 20240513
	if abs(monto - monto_k) > 0.10 then
		mensajeError := 'Existe Discrepancia en los Montos del Documento ...';
		raise exception '%',mensajeError;
	end if;

	iva_factor := (iva * 100) / subtotal;
	iva_factor := round(iva_factor,2);

	-- TO TEST 
	/*raise exception '%', 'Iva Factor : ' || iva_factor::text;*/
	
	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_gastos) <> 'CXP_CONTR_REC_CONVERT_ROLLBACK' then
		raise exception '%', 'Se esta llamando a la funcion [ doc_gastos_comprobar_rollback ] desde una Operacion No Valida ...';
	end if;

	if upper(genero) <> 'X' or upper(naturaleza) <> 'A' then --Cuentas por pagar, Acredora	
		raise exception '%', 'Atributos del Documento [ Genero, Naturaleza ] No Validos ...';
	end if;	
	
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdmm where c1=genero and c2=naturaleza and c3=grupo::int and c4=tipo::int;
	if totalReg = 0 then
		mensajeError := 'Documento no definido en BD ...';
		raise exception '%',mensajeError;			
	end if;

	-- GET KDMM of document 
	expSql = 'select * from keplersc.kdmm where c1='  || E'\'' || genero || E'\'' ||
		' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;	
	select query_to_xml(expSql, true, false, '') into xmlKDMM;
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	if strValor is not null then
		if strValor = 'S' then
			mensajeError := 'Documento no v�lido ...';
			raise exception '%',mensajeError;			
		end if;
	end if;

	folio_operacion := coalesce((xpath('//document/k_folio/text()',dataxml))[1]::text,'')::text;

	if length(folio_operacion) = 0 then
		mensajeError := 'No se pudo obtener el Folio del Documento a Comprobar ...';
		raise exception '%',mensajeError;
	end if;

	refanterior := coalesce((xpath('//document/k_docto/text()',dataxml))[1],'');

	if length(refanterior) = 0 then
		mensajeError := 'No se pudo obtener la Referencia Anterior (Original a Comprobar) del Documento ...';
		raise exception '%',mensajeError;
	end if;

	referencia := coalesce((xpath('//document/k_refer/text()',dataxml))[1]::text,'')::text;

	if length(referencia) = 0 then
		mensajeError := 'No se pudo obtener la Referencia del Documento a Comprobar ...';
		raise exception '%',mensajeError;
	end if;

	proveedor := coalesce((xpath('//document/k_clave_oper/text()',dataxml))[1],'');

	if length(proveedor) = 0 then
		mensajeError := 'No se pudo obtener el Proveedor del Documento a Comprobar ...';
		raise exception '%',mensajeError;
	end if;

	serie_uuid := '';
	folio_uuid := '';
	total_uuid := '';
	impuesto_uuid := '';
	fechatimbrado_uuid := '';

	/*
	serie_uuid := coalesce((xpath('//document/uuid/serie/text()',dataxml))[1]::text,'')::text;
	folio_uuid := coalesce((xpath('//document/uuid/folio/text()',dataxml))[1]::text,'')::text;
	total_uuid := coalesce((xpath('//document/uuid/total/text()',dataxml))[1]::text,'')::text;
	fechatimbrado_uuid := coalesce((xpath('//document/uuid/fechatimbrado/text()',dataxml))[1]::text,'')::text;
	impuesto_uuid := coalesce((xpath('//document/uuid/impuesto/text()',dataxml))[1]::text,'')::text;
	*/
	
	-- Adapted by JMM 20240514 ... gotten of objs k80
	serie_uuid := coalesce((xpath('//document/k_uuid_serie/text()',dataxml))[1]::text,'')::text;
	folio_uuid := coalesce((xpath('//document/k_uuid_folio/text()',dataxml))[1]::text,'')::text;
	total_uuid := coalesce((xpath('//document/k_uuid_monto/text()',dataxml))[1]::text,'')::text;
	fechatimbrado_uuid := coalesce((xpath('//document/k_uuid_fecha/text()',dataxml))[1]::text,'')::text;
	impuesto_uuid := coalesce((xpath('//document/k_uuid_impuesto/text()',dataxml))[1]::text,'')::text;
	
	if length(total_uuid) = 0 or length(fechatimbrado_uuid) = 0 then 
		mensajeError := 'Los Datos Mandatorios del XML (UUID) No estan Completos ...';
		raise exception '%',mensajeError;	
	end if;

	-- Re-Adapted by JMM 20240514
	totalReg := 0;
	-- Func Adaptada para su verificacion solo en las Compras (Entradas) 
	select count(c11) into totalReg from keplersc.kdm1 where c1 = sucursal_id 
			and c2 = 'X' and c3 = 'A' and c11 = referencia
			and upper(coalesce(c43,'')) <> 'C'; /*Added by JMM 20240510*/	 
	if totalReg = /*>*/ 0 then
		/*raise exception '%','El UUID ya ha sido registrado previamente en otro Documento ...';*/
		raise exception '%','No se encontro UUID del Documento a Revertir ...';
	end if;

	-- Re-Adapted by JMM 20240514
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm1 
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and c10 = proveedor and c11 = referencia /*refanterior*/ and upper(st_x_comprobar) = 'X' /*'S'*/
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior;
	if totalReg = 0 then
		/*mensajeError := 'Documento a Comprobar No encontrado en la BD o No tiene el Formato Correcto ...';*/
		mensajeError := 'Documento a Revertir Comprobacion No encontrado en la BD o No tiene el Formato Correcto ...';
		raise exception '%',mensajeError;			
	end if;


	-- Start : Section Vars Data Trans to Follow Up ... by JMM 20240429 

	usuario_movto := coalesce((xpath('//document/movimiento/usuario/text()',dataxml))[1]::text,'')::text;
	hora_movto := coalesce((xpath('//document/movimiento/hora/text()',dataxml))[1]::text,'')::text; 
	--hora_movto := coalesce((xpath('//document/k_hora/text()', dataxml))[1]::text,'')::text;
	hora_movto := substring(hora_movto from 1 for 8/*5*/);

	if length(usuario_movto) = 0 or length(hora_movto) = 0 or length(operacion_desc) = 0  
		or length(fecha_operacion) = 0 or left(trim(fecha_operacion),4) = '1800' then 
		raise exception '%', 'Los Datos de la Operacion No estan Completos [Usuario, Fecha, Hora, Operacion] ...';
	end if;
	
	-- TO TEST 	
	/*raise exception '%', 'Datos Operacion ...' || ' [ ' || operacion_desc || ' , ' || usuario_movto || ' , ' || hora_movto || ' , ' || fecha_operacion || ' ]';*/

	-- End : Section Vars Data Trans to Follow Up ... by JMM 20240429



	--Obtener xml de KDM1 del Documento a Revertir Comprobacion antes de ser Actualizado
	paso:= 'doc_gastos_comprobar.actualizar_DOC';
	expSql = format('select * from keplersc.kdm1 where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L',
		sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion);
	select query_to_xml(expSql, true, false, '') into xmlKDM1;



	---------------------------------------------------------------
	--CONTABILIDAD. ALTA_CONT_DOC_CONVERT_ROLLBACK
	---------------------------------------------------------------
	paso:= 'doc_gastos_comprobar.alta_cont_doc_convert_rollback';
	select * into resultado, mensaje, adicionales from keplersc.alta_cont_doc_convert_rollback(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
	if resultado = '0' then
		raise exception '%', mensaje;
	end if;
	---------------------------------------------------------------
	--FIN CONTABILIDAD.
	---------------------------------------------------------------		



	---------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimientos contables en kdmdocscompr
	--Resuelve: Similar a ALTA_CONT_SEC pero en BAJA_CONT_DOC_COMPR
	---------------------------------------------------------------
	paso:= 'doc_gastos_comprobar.baja_cont_doc_compr';
	select * into resultado, mensaje, adicionales from keplersc.baja_cont_doc_compr(dataxml, folio_operacion);
	if resultado = '0' then
		raise exception '%', mensaje;
	end if;

	-- TO TEST 	
	/*raise exception '%', 'FUN [alta_cont_doc_compr] Ejecutada ...';*/
	


	---------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimiento en kdm1.
	--Resuelve: UPD KDM1 (DOC)
	---------------------------------------------------------------

	-- ACTUALIZACION KDM1 
	update keplersc.kdm1 
	set st_x_comprobar = 'S' /*'X'*/, 
		doc_refer_compl = '' /*refanterior*/,
		fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
		c11 = refanterior /*referencia*/,
		c14 = 0 /*iva*/,
		hora_comprobacion = hora_movto, /*Added by JMM 20240429*/
		usr_comprobacion = usuario_movto, /*Added by JMM 20240429*/
		uuid_serie = '' /*serie_uuid*/, 
		uuid_folio = '' /*folio_uuid*/, 
		uuid_fecha = '' /*fechatimbrado_uuid*/, 
		uuid_total = '' /*total_uuid*/, 
		uuid_impuesto = '' /*impuesto_uuid*/
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and c10 = proveedor and c11 = referencia /*refanterior*/ and upper(st_x_comprobar) = 'X' /*'S'*/ 
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior;
	
	
	-- COMPROBACION ACTUALIZACION KDM1 
	select w.* into rec1 from keplersc.kdm1 w 
	where w.c1 = sucursal_id and w.c2 = genero and w.c3 = naturaleza and w.c4 = grupo::int and w.c5 = tipo::int
		and w.c6 = folio_operacion and w.c10 = proveedor and c11 = refanterior /*referencia*/ and upper(st_x_comprobar) = 'S' /*'X'*/;
	
	if not found then 
		mensajeError := 'No se encontro Registro en KDM1 del Documento Revertido ... ';
		raise exception '%', mensajeError;
	else
		mensajeError := '';
		if rec1.doc_refer_compl <> '' /*refanterior*/ then
			mensajeError := mensajeError || ' | ' || 'Ref Complemento';
		end if;
		--Added by JMM 20240514
		if rec1.c11 <> refanterior then
			mensajeError := mensajeError || ' | ' || 'Referencia';
		end if;
		if rec1.st_x_comprobar <> 'S' /*'X'*/ then
			mensajeError := mensajeError || ' | ' || 'st_x_comprobar';
		end if;
		if to_date(rec1.fecha_comprobacion::text,'YYYY-MM-DD') <> to_date(fecha_operacion,'YYYY-MM-DD') then
			mensajeError := mensajeError || ' | ' || 'fecha_comprobacion';
		end if;
		if rec1.c14 <> 0 /*iva*/ then
			mensajeError := mensajeError || ' | ' || 'iva';
		end if;
		if rec1.hora_comprobacion <> hora_movto then /*Added by JMM 20240429*/
			mensajeError := mensajeError || ' | ' || 'hora_comprobacion';
		end if;
		if rec1.usr_comprobacion <> usuario_movto then /*Added by JMM 20240429*/
			mensajeError := mensajeError || ' | ' || 'usuario_comprobacion';
		end if;
		if length(coalesce(rec1.uuid_fecha,'')) <> /*=*/ 0 then
			mensajeError := mensajeError || ' | ' || 'uuid_fecha';
		end if;
		if length(coalesce(rec1.uuid_total,'')) <> /*=*/ 0 then
			mensajeError := mensajeError || ' | ' || 'uuid_total';
		end if;
	
		if length(mensajeError) > 0 then
			mensajeError := mensajeError || ' | ';
			mensajeError := trim(mensajeError);
			mensajeError := 'Se presentaron inconsistencias en KDM1 en los siguientes campos : ' || mensajeError; 
			raise exception '%', mensajeError;
		end if;
		-- For Testing, It Continuing ...
		/*
		raise exception '%''%''%''%''%''%''%''%''%',
			rec1.c1,rec1.c2,rec1.c3,rec1.c4,rec1.c5,rec1.c6,rec1.c9,rec1.c10,rec1.c11;
		*/
	end if;
	
	-- TO TEST 	
	/*raise exception '%', 'KMD1 Actualizada ...';*/
	
	--Obtener xml de KDM1 del Documento a Comprobar ya Actualizado
	paso:= 'doc_gastos_comprobar.actualizar_DOC';
	expSql = format('select * from keplersc.kdm1 where c1=%1$L and c2=%2$L and c3=%3$L and c4=%4$s and c5=%5$L and c6=%6$L',
		sucursal_id,genero,naturaleza,grupo,tipo,folio_operacion);
	select query_to_xml(expSql, true, false, '') into xmlKDM1;

	--raise notice '%',xmlKDM1;


	------- Start : Section Added by JMM 20240429 ... ADD OPER IN TBL USERACCESS 

	--Block Added by JMM 20240805 ... For Extended Data 
	if length( coalesce(refanterior,'') ) > 0 then
		ref_compl := '[R] ' || refanterior || ' | ';
	end if;
	if length( coalesce(referencia,'') ) > 0 then
		ref_compl := ref_compl || '[C] ' || referencia || ' | ';
	end if;

	if length( ref_compl ) > 0 then
		ref_compl := '[D] ' || rec1.c2 || rec1.c3 || rec1.c4 || rec1.c5 || rec1.c6 || ' | ' || ref_compl;
		-- For Testing, It Continuing ...
		-- raise exception 'ref_compl %', ref_compl;
	else
		raise exception '%', 'No se pudo determinar la Referencia de seguimiento para la Cuenta : ' || referencia;
	end if;

	select xmlforest(usuario_movto as usuario, fecha_operacion/*fecha_movto*/ as fecha, hora_movto as hora, 
		sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
		operacion_desc as tipo_movto , ref_compl as ref_compl/*Added by JMM 20240805*/ ) :: text into strValor;	

	select '<document>'||strValor||'</document>' into strValor;
	xmlUsr := strValor::xml;
		
	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;	

	------- End : Section Added by JMM 20240429 ... ADD OPER IN TBL USERACCESS 
	

	---------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimiento en kduxg, kduxe.
	--Resuelve: UPD KDUXG, KDUXE (CXP PREV REGs)
	---------------------------------------------------------------

	totalReg := 0;
	select count(*) into totalReg from keplersc.kduxg 
	where c1 = sucursal_id and c2 = genero and c3 = proveedor and c4 = referencia /*refanterior*/ and upper(st_x_comprobar) = 'X' /*'S'*/
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior;
	if totalReg = 0 then
		mensajeError := 'C x P {kduxg} del Documento a Revertir No fue encontrado en la BD o No tiene el Formato Correcto ...';
		raise exception '%',mensajeError;			
	end if;

	-- ACTUALIZACION KDUXG 
	update keplersc.kduxg 
	set st_x_comprobar = 'S' /*'X'*/, 
		doc_refer_compl = '' /*refanterior*/,
		fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
		c4 = refanterior /*referencia*/,
		c9 = 0 /*iva*/,
		c8 = 0 /*case when c6 <= 0 then 0 else round( (c6 * iva_factor) / (100 + iva_factor) , 2) end*/
	where c1 = sucursal_id and c2 = genero and c3 = proveedor and c4 = referencia /*refanterior*/ and upper(st_x_comprobar) = 'X' /*'S'*/
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior;
	

	-- COMPROBACION ACTUALIZACION KDUXG 
	select w.* into recg from keplersc.kduxg w 
	where w.c1 = sucursal_id and w.c2 = genero and w.c3 = proveedor and w.c4 = refanterior /*referencia*/ and upper(w.st_x_comprobar) = 'S' /*'X'*/;
	
	if not found then 
		mensajeError := 'No se encontro Registro en KDUXG de la CxP Comprobada ... ';
		raise exception '%', mensajeError;
	else
		mensajeError := '';
		if recg.doc_refer_compl <> '' /*refanterior*/ then
			mensajeError := mensajeError || ' | ' || 'Ref Complemento';
		end if;
		--Added by JMM 20240514 
		if recg.c4 <> refanterior then
			mensajeError := mensajeError || ' | ' || 'Referencia';
		end if;
		if recg.st_x_comprobar <> 'S' /*'X'*/ then
			mensajeError := mensajeError || ' | ' || 'st_x_comprobar';
		end if;
		if to_date(recg.fecha_comprobacion::text,'YYYY-MM-DD') <> to_date(fecha_operacion,'YYYY-MM-DD') then
			mensajeError := mensajeError || ' | ' || 'fecha_comprobacion';
		end if;
	
		if length(mensajeError) > 0 then
			mensajeError := mensajeError || ' | ';
			mensajeError := trim(mensajeError);
			mensajeError := 'Se presentaron inconsistencias en KDUXG en los siguientes campos : ' || mensajeError; 
			raise exception '%', mensajeError;
		end if;
	
		-- Verifying UPD IVA KDUXG
		-- N.A. for this option
		/*if iva > 0 then
			
			if recg.c9 <> iva then
				mensajeError := 'Inconsistencia en Registro de IVA [Kduxg]';
				raise exception '%', mensajeError;
			end if;
			if recg.c6 > 0 then
				if recg.c8 <> round( (recg.c6 * iva_factor) / (100 + iva_factor) , 2) then
					mensajeError := 'Inconsistencia en Registro de de Cargos de IVA [Kduxg]';
					raise exception '%', mensajeError;
				end if;
			end if;
		
			--Added 20240407 to fix round decs dif 
			if abs(recg.c9 - recg.c8) > 0 and abs(recg.c9 - recg.c8) <= 0 + .10 then
				update keplersc.kduxg 
				set c8 = c9
				where c1 = sucursal_id and c2 = genero and c3 = proveedor and c4 = referencia and upper(st_x_comprobar) = 'X';
			end if;
			
		
		else*/
			if abs(recg.c9) <> 0 /*+ .10*/ then
				mensajeError := 'Inconsistencia en Registro de de Abonos de IVA [Kduxg]';
				raise exception '%', mensajeError;
			end if;
			if abs(recg.c8) <> 0 /*+ .10*/ then
				mensajeError := 'Inconsistencia en Registro de de Cargos de IVA [Kduxg]';
				raise exception '%', mensajeError;
			end if;
		/*end if;*/
	
		--Added 20240407 to eval st doc  
		if ( abs(recg.c7 - recg.c6) > 0 and abs(recg.c7 - recg.c6) <= 0 + .10 ) or recg.c7 = recg.c6 then
			update keplersc.kduxg 
			set c10 = 10
			where c1 = sucursal_id and c2 = genero and c3 = proveedor and c4 = refanterior /*referencia*/ and upper(st_x_comprobar) = 'S' /*'X'*/;
		end if;
	
	end if;

	-- TO TEST 	
	/*raise exception '%', 'KDUXG Actualizada ...';*/

	totalReg := 0;
	select count(*) into totalReg from keplersc.kduxe 
	where c1 = sucursal_id and c5 = genero and c2 = proveedor and c3 = referencia /*refanterior*/
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior /*Added by JMM 20240725*/ and c13 > 0;
	if totalReg = 0 then
		mensajeError := 'C x P {kduxe} del Documento a Revertir No fue encontrado en la BD o No tiene el Formato Correcto ...';
		raise exception '%',mensajeError;			
	end if;

	-- ACTUALIZACION KDUXE  
	update keplersc.kduxe 
	set doc_refer_compl = '' /*refanterior*/,
		fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
		c3 = refanterior /*referencia*/, 
		c14 = 0 /*case when (c5 || c6) = 'XA' then iva else case when (c5 || c6) = 'XD' then round( (c13 * iva_factor) / (100 + iva_factor) , 2) else c14 end end*/
	where c1 = sucursal_id and c5 = genero and c2 = proveedor and c3 = referencia /*refanterior*/
		/*Added by JMM 20240724*/ and doc_refer_compl = refanterior /*Added by JMM 20240725*/ and c13 > 0;

	-- COMPROBACION ACTUALIZACION KDUXE 
	totalReg := 0;
	select count(w.*) into totalReg from keplersc.kduxe w 
	where w.c1 = sucursal_id and w.c5 = genero and w.c2 = proveedor and w.c3 = refanterior /*referencia*/
		/*Added by JMM 20240725*/ and w.c13 > 0;
	if totalReg = 0 then
		mensajeError := 'No se encontraron Registros en KDUXE de la CxP Comprobada ... ';
		raise exception '%', mensajeError;
	else
		for rece in 
			select w.* from keplersc.kduxe w  
			/*inner join keplersc.kdm1 m on m.c1 = w.c1 and m.c2 = w.c5 and m.c3 = w.c6 and m.c4 = w.c7 and m.c5 = w.c8 and m.c6 = w.c9*/
			where w.c1 = sucursal_id and w.c5 = genero and w.c2 = proveedor and w.c3 = refanterior /*referencia*/ 
				/*Added by JMM 20240725*/ and w.c13 > 0 
		loop
			
			/*raise exception '%', 'Entro al For ... Kduxe';*/
			
			mensajeError := '';
			if rece.doc_refer_compl <> '' /*refanterior*/ then
				mensajeError := mensajeError || ' | ' || 'Ref Complemento';
			end if;
			--Added by JMM 20240514
			if rece.c3 <> refanterior then
				mensajeError := mensajeError || ' | ' || 'Referencia';
			end if;
			if to_date(rece.fecha_comprobacion::text,'YYYY-MM-DD') <> to_date(fecha_operacion,'YYYY-MM-DD') then
				mensajeError := mensajeError || ' | ' || 'fecha_comprobacion';
			end if;
		
			if length(mensajeError) > 0 then
				mensajeError := mensajeError || ' | ';
			
				/*Added by JMM 20240725*/
				mensajeError := mensajeError || 'Docto. ' || rece.c5 || rece.c6 || rece.c7::text || rece.c8::text || rece.c9;
				mensajeError := mensajeError || ' | ';
			
				mensajeError := trim(mensajeError);
				mensajeError := 'Se presentaron inconsistencias en KDUXE en los siguientes campos : ' || mensajeError; 
				raise exception '%', mensajeError;
			end if;
		
			-- Verifying UPD IVA KDUXE
			-- N.A. for this option
			/*if iva > 0 then 
				if (rece.c5 || rece.c6) = 'XA' then
					if rece.c14 <> iva then
						mensajeError := 'Inconsistencia en Registro de IVA [Kduxe]';
						raise exception '%', mensajeError;
					end if;
				end if;
				if (rece.c5 || rece.c6) = 'XD' then
					if rece.c14 <> round( (rece.c13 * iva_factor) / (100 + iva_factor) , 2) then
						mensajeError := 'Inconsistencia en Registro de de Cargos de IVA [Kduxe]';
						raise exception '%', mensajeError;
					end if;
				end if;
			else*/
				if abs(rece.c14) <> 0 /*+ .10*/ then
					mensajeError := 'Inconsistencia en Registro de de Cargos de IVA [Kduxe]';
					raise exception '%', mensajeError;
				end if;
			/*end if;*/
		
		end loop;
	end if;
	
	-- TO TEST 	
	/*raise exception '%', 'KDUXE Actualizada ...';*/	
			

	-----------  START : Section KDM5 Added by JMM 20240514

	for rec5 in 
		select * from keplersc.kdm5 where (c1||c2||c3||c4::text||c5::text||c6) in (
			select (c1||c5||c6||c7::text||c8::text||c9) from keplersc.kduxe where c1 = sucursal_id and c5 = 'X' and c6 = 'D' 
				and c3 = refanterior and c2 = proveedor /*Added by JMM 20240725*/ and c13 > 0 
		) and cve_prov_oper = proveedor and c14 = referencia 
	loop
		
		--To Test 
		--raise exception '%', '[For Kdm5] Referencia : ' || referencia;
		
		if /*rec5.c14 <> refanterior or*/ rec5.c14 = referencia and rec5.cve_prov_oper = proveedor then 
		
			--Added by JMM 20240725
			iva_ciclo := 0;
			select e.c14 into iva_ciclo from keplersc.kduxe e 
			where e.c1 = rec5.c1 and e.c5 = rec5.c2 and e.c6 = rec5.c3 and e.c7 = rec5.c4 and e.c8 = rec5.c5 and e.c9 = rec5.c6 
				and e.c3 = refanterior /*referencia*/ and e.c2 = proveedor and e.c13 > 0 and e.doc_refer_compl = ''/*refanterior*/;
			iva_ciclo := coalesce(iva_ciclo, -0.00001);
			if iva_ciclo < -0.00001 then
				raise exception '%', 'No se pudo obtener Info del Pago [kduxe], Docto. : ' || rec5.c2 || rec5.c3 || rec5.c4::text || rec5.c5::text || rec5.c6;
			end if;
		
			-- To Test ...
			--raise exception '%', '[iva_ciclo] : ' || iva_ciclo;
		
			update keplersc.kdm5 
			set fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
				c14 = refanterior, 
				c13 = 0 
			where c1 = rec5.c1 and c2 = rec5.c2 and c3 = rec5.c3 and c4 = rec5.c4 and c5 = rec5.c5 
				and c6 = rec5.c6 and c7 = rec5.c7 and c14 = rec5.c14 and cve_prov_oper = rec5.cve_prov_oper;
			
		end if;
	
	end loop;

	--end loop;

	-- To check if is necesary including validation 
	-- COMPROBACION ACTUALIZACION KDM5 
	totalReg := 0;
	-- Commented by JMM 20240724
	/*
	select count(m.*) into totalReg from keplersc.kdm5 m 
	where m.c1 = sucursal_id and m.c2 = 'X' and m.c3 = 'D' and m.cve_prov_oper = proveedor and m.c14 = /*refanterior*/ referencia;
	*/
	-- Adapted by JMM 20240724 , Expanded by JMM 20240725 (For Loop To Get Docs.Issues)
	/*
	select count(m.*) into totalReg from keplersc.kdm5 m 
	inner join keplersc.kdm1 w on w.c1 = m.c1 and w.c2 = m.c2 and w.c3 = m.c3 and w.c4 = m.c4 and w.c5 = m.c5 and w.c6 = m.c6 
	where m.c1 = sucursal_id and m.c2 = 'X' and m.c3 = 'D' and m.cve_prov_oper = proveedor and m.c14 = /*refanterior*/ referencia
		and w.c16 > 0 and upper(w.c43) <> 'C';
	*/
	-- Fixed by JMM 20240814 ... To Consider Transfers, past sentence only consider checks (Cancel Dos)
	select count(m.*) into totalReg from keplersc.kdm5 m 
	inner join keplersc.kdm1 w on w.c1 = m.c1 and w.c2 = m.c2 and w.c3 = m.c3 and w.c4 = m.c4 and w.c5 = m.c5 and w.c6 = m.c6 
	where m.c1 = sucursal_id and m.c2 = 'X' and m.c3 = 'D' and m.cve_prov_oper = proveedor and m.c14 = /*refanterior*/ referencia
		and w.c16 > 0 
		and ( (m.c4::int = 31 and m.c5::int = 1 and upper(w.c43) <> 'C') or (m.c4::int = 33 and m.c5::int = 11 and upper(m.st_x_comprobar) <> 'N') );

	if abs(totalReg) > 0 then
	
		--Added by JMM 20240725 
		mensajeError := '';
		counter := 0;
		for rect in 
			/*
			select m.* from keplersc.kdm5 m 
			inner join keplersc.kdm1 w on w.c1 = m.c1 and w.c2 = m.c2 and w.c3 = m.c3 and w.c4 = m.c4 and w.c5 = m.c5 and w.c6 = m.c6 
			where m.c1 = sucursal_id and m.c2 = 'X' and m.c3 = 'D' and m.cve_prov_oper = proveedor and m.c14 = /*refanterior*/ referencia
				and w.c16 > 0 and upper(w.c43) <> 'C'
			*/
			-- Fixed by JMM 20240814 ... To Consider Transfers, past sentence only consider checks (Cancel Dos)
			select m.* from keplersc.kdm5 m 
			inner join keplersc.kdm1 w on w.c1 = m.c1 and w.c2 = m.c2 and w.c3 = m.c3 and w.c4 = m.c4 and w.c5 = m.c5 and w.c6 = m.c6 
			where m.c1 = sucursal_id and m.c2 = 'X' and m.c3 = 'D' and m.cve_prov_oper = proveedor and m.c14 = /*refanterior*/ referencia
				and w.c16 > 0 
				and ( (m.c4::int = 31 and m.c5::int = 1 and upper(w.c43) <> 'C') or (m.c4::int = 33 and m.c5::int = 11 and upper(m.st_x_comprobar) <> 'N') ) 
		loop
			counter := counter + 1;
			if counter <= 4 then
				mensajeError := mensajeError || /*' | ' ||*/ ' [ Doc ] ' || rect.c2 || '.' || rect.c3 || '.' || rect.c4::text || '.' || rect.c5::text || '.' || rect.c6;
			else
				mensajeError := mensajeError || ' | ' || ' [ Doc ] ' || rect.c2 || '.' || rect.c3 || '.' || rect.c4::text || '.' || rect.c5::text || '.' || rect.c6;
				counter := 1;
			end if;
			mensajeError := mensajeError || ' ; ';
		end loop;
	
		if length(mensajeError) > 0 then
			mensajeError := left(mensajeError, length(mensajeError) - 3);
		end if;
	
		--Commented & Adapted by JMM 20240725
		--mensajeError := 'Se encontraron discrepancias en KDM5 de la CxP Revertida ... ';
		mensajeError := mensajeError || ' | ';
		mensajeError := trim(mensajeError);
		mensajeError := ' ' || ' | ' || ' ' || ' | ' || 'Existen documentos que se hicieron despues de la Comprobacion, para poder Revertir la Comprobacion deben cancelarse primero.'
			|| ' | ' || ' ' || ' | ' || 'Si se cancelan con este fin, debes asegurarte de registralos nuevamente para mantener el Saldo correcto de la  C x P (si asi aplicara)'
			|| ' | ' || ' ' || ' | ' || mensajeError; 
			
		raise exception '%', mensajeError;
	
	end if;

	-- TO TEST 	
	/*raise exception '%', 'KDM5 Actualizada ...';*/

	-----------  END : Section KDM5 Added by JMM 20240514


	-- For Testing ...
	--raise exception '%','El Documento sera Revertido en su Comprobacion ...';

	resultado := 1;
	mensaje := ''/*folio_poliza*/;
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'doc_gastos_comprobar_rollback() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

END;
$function$
