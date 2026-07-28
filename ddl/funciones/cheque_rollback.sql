CREATE OR REPLACE FUNCTION keplersc.cheque_rollback(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
DECLARE 
	--Esta funcion procesa los tipos de documentos X, D ( Pagos - Cheques ) a darse de Baja
	--Se controlara con un TAG en el XML  
	--No pasara por docdis, no se creara Docmento en KDM1 ni Cuenta por Pagar KDUXG, KDUXE 
	--pero estas Tablas seran Actualizadas con los Datos del XML asociado en la Operacion 
	--Esta Funcion solo es Accesible en el Modulo de Gastos 
	--Funcionara solo para los Registros Generados con el Nuevo Esquema donde se usan : 
	--Proveedores de Operacion y de Pago
	--Autor: Jose Mendoza , 16 Mayo 2024
	-- * * * Control de Cambios :

	
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
	/*refanterior text = '';*/ -- Commented by JMM 20240417 
	proveedor text = '';
	fecha_operacion text;
	iva numeric = 0;	
	monto numeric = 0;	
	subtotal numeric = 0;
	/*iva_factor numeric = 0;*/ -- Commented by JMM 20240417 
	strMonto text = '';

	rec1 record;
	rec5 record;
	recg record;
	rece record;

	--Added by JMM 20240417 ... 20240418
	docto text = '';
	hora_movto text = '';
	usuario_movto text = '';
	intCont int = 0;
	numero_partida int = 0;
	no_vacios int = 0;
	no_partidas int = 0;
	-- Vars Grid 
	prov_pago text = '';
	nombre text = '';
	factura text = '';
	prov_oper text = '';
	st_del text = '';
	partida text = '';
	p_iva text = '';
	p_monto text = '';
	p_iva_n numeric = 0;
	p_monto_n numeric = 0;
	partida_n numeric = 0;


	monto_bef numeric = 0;
	iva_bef numeric = 0;
	monto_aft numeric = 0;
	iva_aft numeric = 0;


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
	
	--Added by JMM 20240516
	totalRegk5 int;
	
	--Added by JMM 20240426
	get_resultado text = '';
	get_mensaje text = '';
	get_adicionales text = '';
	operacion_desc text = '';
	xmlUsr xml;	
	
begin
	-- Inicializacion de variables
	/*folio_operacion := 0;*/
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

	operacion_desc := coalesce((xpath('//document/operacion/text()', dataxml))[1],''); /*Added by JMM 20240426*/

	-- Adapted by JMM 20240516
	/*fecha_operacion := coalesce((xpath('//document/k_fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;*/
	fecha_operacion := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;

	strMonto := coalesce((xpath('//document/k_iva/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	iva := strMonto::decimal;
	strMonto := coalesce((xpath('//document/k_monto/text()', dataxml))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	monto := strMonto::decimal;

	subtotal := monto - iva;

	if monto <= 0 then
		mensajeError := 'El Monto de la Operacion No puede ser menor a cero ...'; /*o igual*/
		raise exception '%',mensajeError;
	end if;

	--Commented by JMM 20240417
	/*
	iva_factor := (iva * 100) / subtotal;
	iva_factor := round(iva_factor,2);
	*/

	-- TO TEST 
	/*raise exception '%', 'Iva Factor : ' || iva_factor::text;*/
	
	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;

	if upper(flag_gastos) <> 'CXP_CHEQUE_BAJA' then
		raise exception '%', 'Se esta llamando a la funcion [ cheque_rollback ] desde una Operacion No Valida ...';
	end if;

	if upper(genero) <> 'X' or upper(naturaleza) <> 'D' then --Cuentas por pagar, Deudora	
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
			mensajeError := 'Documento no v?lido ...';
			raise exception '%',mensajeError;			
		end if;
	end if;

	folio_operacion := coalesce((xpath('//document/k_folio/text()',dataxml))[1]::text,'')::text;

	if length(folio_operacion) = 0 then
		mensajeError := 'No se pudo obtener el Folio del Documento a Cancelar (Actualizar) ...';
		raise exception '%',mensajeError;
	end if;

	docto := coalesce((xpath('//document/k_docto/text()',dataxml))[1],'');

	referencia := coalesce((xpath('//document/k_refer/text()',dataxml))[1]::text,'')::text;

	if length(referencia) = 0 then
		mensajeError := 'No se pudo obtener la Referencia del Documento a Cancelar ...';
		raise exception '%',mensajeError;
	end if;

	-- Commented by JMM 20240417 
	/*
	proveedor := coalesce((xpath('//document/k_clave_oper/text()',dataxml))[1],'');

	if length(proveedor) = 0 then
		mensajeError := 'No se pudo obtener el Proveedor del Documento a Comprobar ...';
		raise exception '%',mensajeError;
	end if;
	*/

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm1 
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion /*and c10 = proveedor and c11 = refanterior and upper(st_x_comprobar) = 'S'*/
		and c11 = referencia and upper(coalesce(st_x_comprobar,'')) <> 'B' /*= 'T'*/ and upper(c43) <> 'C'/*Added by JMM 20240416*/;
	if totalReg = 0 then
		mensajeError := 'Documento a Cancelar No encontrado en la BD o No tiene el Formato Correcto ...';
		raise exception '%',mensajeError;			
	end if;

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


	---------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimiento en kdm1.
	--Resuelve: UPD KDM1 (DOC)
	---------------------------------------------------------------

	-- ACTUALIZACION KDM1 
	update keplersc.kdm1 
	set st_x_comprobar = 'B'/*'V'*//*'X'*/, 
		fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
		c14 = 0 /*iva*/,
		c16 = 0 /*monto*/,
		c42 = 0 /*saldo*/,
		c43 = 'C' /*ST Cancel*/,
		c197 = current_date /*Fecha Baja*/,
		hora_comprobacion = hora_movto,
		usr_comprobacion = usuario_movto /*Added by JMM 20240426*/
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion /*and c10 = proveedor and c11 = refanterior and upper(st_x_comprobar) = 'S';*/
		and c11 = referencia and upper(coalesce(st_x_comprobar,'')) <> 'B'/*= 'T'*/ and upper(c43) <> 'C'/*Added by JMM 20240416*/;
	
	-- COMPROBACION ACTUALIZACION KDM1 
	select w.* into rec1 from keplersc.kdm1 w 
	where w.c1 = sucursal_id and w.c2 = genero and w.c3 = naturaleza and w.c4 = grupo::int and w.c5 = tipo::int
		and w.c6 = folio_operacion /*and w.c10 = proveedor and c11 = referencia and upper(st_x_comprobar) = 'X';*/
		and c11 = referencia and st_x_comprobar = 'B';
	
	if not found then 
		mensajeError := 'No se encontro Registro en KDM1 de la CxP Cancelada (Actualizada) ... ';
		raise exception '%', mensajeError;
	else
		mensajeError := '';
		if rec1.st_x_comprobar <> 'B'/*'X'*/ then
			mensajeError := mensajeError || ' | ' || 'st_x_comprobar';
		end if;
		if rec1.c43 <> 'C' then /*Added by JMM 20240516*/
			mensajeError := mensajeError || ' | ' || 'st_cancelado';
		end if;
		if to_date(rec1.fecha_comprobacion::text,'YYYY-MM-DD') <> to_date(fecha_operacion,'YYYY-MM-DD') then
			mensajeError := mensajeError || ' | ' || 'fecha_comprobacion';
		end if;
		if rec1.c14 <> 0 /*iva*/ then
			mensajeError := mensajeError || ' | ' || 'iva';
		end if;
		if rec1.c16 <> 0 /*monto*/ then
			mensajeError := mensajeError || ' | ' || 'total';
		end if;
		if rec1.c42 <> 0 /*saldo*/ then /*Added by JMM 20240516*/
			mensajeError := mensajeError || ' | ' || 'saldo';
		end if;
		if rec1.hora_comprobacion <> hora_movto then /*Added by JMM 20240426*/
			mensajeError := mensajeError || ' | ' || 'hora_comprobacion';
		end if;
		if rec1.usr_comprobacion <> usuario_movto then /*Added by JMM 20240426*/
			mensajeError := mensajeError || ' | ' || 'usuario_comprobacion';
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


	------- Start : Section Added by JMM 20240426 ... ADD OPER IN TBL USERACCESS 

	select xmlforest(usuario_movto as usuario, fecha_operacion/*fecha_movto*/ as fecha, hora_movto as hora, 
		sucursal_id as sucursal, genero, naturaleza, grupo, tipo, folio_operacion as folio,
		operacion_desc as tipo_movto) :: text into strValor;	

	select '<document>'||strValor||'</document>' into strValor;
	xmlUsr := strValor::xml;
		
	select * into get_resultado, get_mensaje, get_adicionales from keplersc.usr_kdusraccess_alta(xmlUsr);
	if get_resultado = '0' then
		raise exception '%',get_mensaje;
	end if;	

	------- End : Section Added by JMM 20240426 ... ADD OPER IN TBL USERACCESS 
	

	---------------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimiento en kdm5 (Transfer) 
	--Resuelve: UPD KDM5 (DOC)
	--Identificacion de Partidas a Revertir en esta Operacion (Paso 1/2)
	---------------------------------------------------------------------

	-- AQUI VA UPD 1/2 DE KDM5


	--  * * *  Validar Datos - Partidas ...

    no_partidas := 0;
	strValor := coalesce((xpath('//document/k_mov/no_partidas/text()',dataxml))[1]::text,'0');
	no_partidas := strValor::integer;

	if no_partidas <= 0 then
		mensaje := 'No hay partidas a Procesar ...';
		raise exception '%', mensaje;	
	end if;

	numero_partida = 0;

	for intCont in 0..no_partidas - 1 loop
		
		no_vacios := 0;
			
		/*prov_pago := coalesce((xpath('//document/k_mov/r'||intCont||'/k_clave/text()',dataxml))[1],'');*/ -- no estara en las partidas
		prov_pago := coalesce((xpath('//document/k_clave/text()',dataxml))[1]::text,'')::text;
	
		-- N.A. nombre := coalesce((xpath('//document/k_mov/r'||intCont||'/k_nombreprov/text()',dataxml))[1],'');
		factura := coalesce((xpath('//document/k_mov/r'||intCont||'/k_factura/text()',dataxml))[1],'');
		prov_oper := coalesce((xpath('//document/k_mov/r'||intCont||'/k_prov/text()',dataxml))[1],'');
		p_iva := coalesce((xpath('//document/k_mov/r'||intCont||'/k_iva_factura/text()',dataxml))[1],'');
		p_monto := coalesce((xpath('//document/k_mov/r'||intCont||'/k_monto_factura/text()',dataxml))[1],'');
		-- N.A. partida := coalesce((xpath('//document/k_mov/r'||intCont||'/partida/text()',dataxml))[1],'');	
	
		/*st_del := coalesce((xpath('//document/k_mov/r'||intCont||'/borrar/text()',dataxml))[1],'');*/
	
		if length(prov_pago) > 0 then no_vacios := no_vacios + 1; end if;
		-- N.A. if length(nombre) > 0 then no_vacios := no_vacios + 1; end if;
		if length(factura) > 0 then no_vacios := no_vacios + 1; end if;
		if length(prov_oper) > 0 then no_vacios := no_vacios + 1; end if;
		if length(p_iva) > 0 then no_vacios := no_vacios + 1; end if;
		if length(p_monto) > 0 then no_vacios := no_vacios + 1; end if;
		-- N.A. if length(partida) > 0 then no_vacios := no_vacios + 1; end if;

		if no_vacios < 5 /*7*/ and no_vacios > 0 then 
			mensaje := 'Partidas con datos incompletos ... ' 
				|| chr(13) || ' ' || chr(13) || 'Puede ocurrir por No contar con un Formato o Esquema Valido.';
			raise exception '%', mensaje;	
		end if;
	
		/*partida_n := partida::numeric;*/
	
		if no_vacios > 0 then
		
			-- Validar datos de catalogos & valores ...
		
			/*
			 
			item_part := '';
			/*
			if length(reemplazo) > 0 and upper(operacion) = 'ALTA' then
				item_part := original;
				mensaje := 'No se encontro el Registro en la Tabla kdinr [Reemplazo] [' || parte || ']';
			else
			*/
				item_part := parte;
				mensaje := 'No se encontro el Registro en la Tabla Kdini [Producto] [' || parte || ']';
			/*end if;*/
		
			totReg := 0;
			select count(c1) into totReg from keplersc.kdini where c1 = item_part/*parte*/;
			if totReg = 0 then
				raise exception '%', mensaje;
			else
				mensaje := '';
			end if;	
				
			if length(entr_fech) > 0 and (length(entr_st) = 0 or entr_st::int = 0) and entr_fech::date <> current_date then 
				mensaje := 'La Fecha de Entregado No puede ser diferente al dia de Hoy ... Parte [' || parte || '] , Fecha Entregado [' || entr_fech || ']';
				raise exception '%', mensaje;	
			end if;
		
			*/
		
			--Adapted by JMM 20240516, Se procesaran todas las partidas ...
			/*if length(st_del) > 0 and upper(st_del) = upper('X') then*/ 
			
				numero_partida := numero_partida + 1;
			
				-- Se Actualizara con un Estatus Parcial la partida en KDM5 
			
				-- validar datos en kdm5 
				totalReg := 0;
				select count(*) into totalReg from keplersc.kdm5  
				where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
					and c6 = folio_operacion /*and c7 = partida_n*/ and c14 = factura 
					and cve_prov_oper = prov_oper and cve_prov_pago = prov_pago;
				if totalReg = 0 then
					mensaje := 'No se encontro el Registro en kdm5 [Ref.] [' || factura || ']' 
						|| chr(13) || ' ' || chr(13) || 'Esto puede deberse a una Comprobacion Intermedia si la CxP es un Contrarecibo.' 
						|| chr(13) || ' ' || chr(13) || 'Otra causa probable es que No tiene un Formato Valido {Nuevo Esquema Gastos}';
					raise exception '%', mensaje;
				else
					-- ACTUALIZACION KDM5 1/2 ( ST = X ) 
					update keplersc.kdm5 
					set st_x_comprobar = 'X', 
						fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD'),
						hora_comprobacion = hora_movto,
						usr_comprobacion = usuario_movto 
					where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
						and c6 = folio_operacion /*and c7 = partida_n*/ and c14 = factura 
						and cve_prov_oper = prov_oper and cve_prov_pago = prov_pago;
				end if;
			
			/*end if;*/
		
		end if;
	
	end loop;	

	if numero_partida = 0 then
		mensaje := 'Despues de validar la INFO, No se encontraron partidas a Procesar ...';
		raise exception '%', mensaje; 
	end if; 


	-- Added by JMM 20240516
	-- Obtener Registros de KDM5 del DOC x CANCEL para verificar que se hayan marcado todos los Registros
	totalRegk5 := 0;
	select count(*) into totalRegk5 from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion /*and st_x_comprobar = 'X' and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto*/;
	if totalRegk5 = 0 then
		mensaje := 'No se encontraron Registros en kdm5 del Documento a Procesar ...';
		raise exception '%', mensaje;
	end if;


	-- Validar Existencia de Datos a Procesar en KDM5 (sera la base para las TRNs de CxP & CT)
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and st_x_comprobar = 'X' and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto;
	if totalReg = 0 then
		mensaje := 'No se encontraron Registros a Procesar en kdm5 ... Paso 1/2';
		raise exception '%', mensaje;
	end if;


	-- Added by JMM 20240516
	if totalRegk5 <> totalReg then 
		mensaje := 'Existen Discrepancias entre los Registros del Documento y los Registros a Procesar en kdm5 ... Paso 1/2';
		raise exception '%', mensaje;
	end if;


	-- TO TEST 	
	/*raise exception '%', 'KMD5 por Actualizar 1/2 ...';*/


	---------------------------------------------------------------
	--MOVIMIENTOS. Registro de movimiento en kduxg, kduxe.
	--Resuelve: UPD KDUXG, KDUXE (CXP PREV REGs)
	---------------------------------------------------------------


	for rec5 in 
		select * from keplersc.kdm5   
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
			and c6 = folio_operacion and st_x_comprobar = 'X' and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
			and hora_comprobacion = hora_movto 
	loop
		
		-- * * * UPD KDUXG
		totalReg := 0;
		select count(*) into totalReg from keplersc.kduxg 
		where c1 = sucursal_id and c2 = genero and (c4 = rec5.c14 or doc_refer_compl = rec5.c14) 
			and c3 = rec5.cve_prov_oper 
			and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
		if totalReg = 0 then
			mensajeError := 'C x P {kduxg} de la Partida a Procesar {kdm5} No fue encontrado en la BD o No tiene el Formato Correcto ...';
			raise exception '%',mensajeError;
		else
			monto_bef := 0; iva_bef := 0; monto_aft := 0; iva_aft := 0;
			--/*
			select c6, coalesce(c8,0) into monto_bef, iva_bef from keplersc.kduxg 
			where c1 = sucursal_id and c2 = genero and (c4 = rec5.c14 or doc_refer_compl = rec5.c14) 
				and c3 = rec5.cve_prov_oper 
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			--*/
			-- ACTUALIZACION KDUXG 
			update keplersc.kduxg 
			set c6 = c6 - rec5.c12, 
				c8 = c8 - case when rec5.c13 <> 0 then rec5.c13 else 0 end,
				c10 = 0
			where c1 = sucursal_id and c2 = genero and (c4 = rec5.c14 or doc_refer_compl = rec5.c14) 
				and c3 = rec5.cve_prov_oper 
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			--/*
			select c6, coalesce(c8,0) into monto_aft, iva_aft from keplersc.kduxg 
			where c1 = sucursal_id and c2 = genero and (c4 = rec5.c14 or doc_refer_compl = rec5.c14) 
				and c3 = rec5.cve_prov_oper 
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			--*/
			if monto_bef - rec5.c12 <> monto_aft then
				raise exception '%', 'Inconsistencia en Total Evaluado { Kduxg } ... REF : ' || rec5.c14;
			end if;
			if iva_bef - coalesce(rec5.c13,0) <> iva_aft then
				raise exception '%', 'Inconsistencia en IVA Evaluado { Kduxg } ... REF : ' || rec5.c14;
			end if;
		end if;
		-- * * * END : UPD KDUXG
	
		-- * * * UPD KDUXE
		totalReg := 0;
		select count(*) into totalReg from keplersc.kduxe 
		where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::int and c8 = tipo::int
			and c9 = folio_operacion and (c3 = rec5.c14 or doc_refer_compl = rec5.c14) and c2 = rec5.cve_prov_oper
			and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
		if totalReg = 0 then
			mensajeError := 'C x P {kduxe} de la Partida a Procesar {kdm5} No encontrado en la BD o No tiene el Formato Correcto ...';
			raise exception '%',mensajeError;	
		else
			monto_bef := 0; iva_bef := 0; monto_aft := 0; iva_aft := 0;
			-- /*
			select c13, coalesce(c14,0) into monto_bef, iva_bef from keplersc.kduxe 
			where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::int and c8 = tipo::int
				and c9 = folio_operacion and (c3 = rec5.c14 or doc_refer_compl = rec5.c14) and c2 = rec5.cve_prov_oper
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			-- */
			-- ACTUALIZACION KDUXE  
			update keplersc.kduxe 
			set hora_comprobacion = hora_movto,
				fecha_rollback = to_date(fecha_operacion,'YYYY-MM-DD'),
				monto_rollback = rec5.c12, 
				iva_rollback = coalesce(rec5.c13,0),
				c13 = 0, c14 = 0
			where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::int and c8 = tipo::int
				and c9 = folio_operacion and (c3 = rec5.c14 or doc_refer_compl = rec5.c14) and c2 = rec5.cve_prov_oper
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			-- /*
			select c13, coalesce(c14,0) into monto_aft, iva_aft from keplersc.kduxe 
			where c1 = sucursal_id and c5 = genero and c6 = naturaleza and c7 = grupo::int and c8 = tipo::int
				and c9 = folio_operacion and (c3 = rec5.c14 or doc_refer_compl = rec5.c14) and c2 = rec5.cve_prov_oper
				and cve_prov_pago = case when length(coalesce(cve_prov_pago,'')) = 0 then cve_prov_pago else rec5.cve_prov_pago end;
			-- */
			if monto_bef - rec5.c12 <> monto_aft then
				raise exception '%', 'Inconsistencia en Total Evaluado { Kduxe } ... REF : ' || rec5.c14;
			end if;
			if iva_bef - coalesce(rec5.c13,0) <> iva_aft then
				raise exception '%', 'Inconsistencia en IVA Evaluado { Kduxe } ... REF : ' || rec5.c14;
			end if;
		end if;
		-- * * * END : UPD KDUXE
	
	end loop;


	-- TO TEST 	
	/*raise exception '%''monto bef%''iva bef%''monto aft%''iva aft%', 'CxP was matched on Kduxg ...',monto_bef,iva_bef,monto_aft,iva_aft;*/
	/*raise exception '%', 'CxP(s) was evaluated { Kduxg } ...';*/
	/*raise exception '%', 'CxP(s) was evaluated { Kduxe } ...';*/


	---------------------------------------------------------------
	--CONTABILIDAD. ALTA_CONT_TRANSFER_ROLLBACK
	---------------------------------------------------------------
	paso:= 'doc_gastos_comprobar.alta_cont_cheque_rollback';
	select * into resultado, mensaje, adicionales from keplersc.alta_cont_cheque_rollback(dataxml,xmlKDM1,xmlKDMM,folio_operacion);
	if resultado = '0' then
		raise exception '%', mensaje;
	end if;
	---------------------------------------------------------------
	--FIN CONTABILIDAD.
	---------------------------------------------------------------					
		

	-- validar datos en kdm5 
	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and st_x_comprobar = 'X' 
		and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto and usr_comprobacion = usuario_movto;
	if totalReg = 0 then
		mensaje := 'No se encontraron Registros en kdm5 para completar la Operacion ... 2/2';
		raise exception '%', mensaje;
	else
		-- ACTUALIZACION KDM5 2/2 ( ST = X -> N ) 
		update keplersc.kdm5 
		set st_x_comprobar = 'N'  
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
			and c6 = folio_operacion and st_x_comprobar = 'X' 
			and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
			and hora_comprobacion = hora_movto and usr_comprobacion = usuario_movto;
	end if;

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and st_x_comprobar = 'X' 
		and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto and usr_comprobacion = usuario_movto;
	if totalReg > 0 then
		mensaje := 'Se encontraron Registros Discrepantes de la Operacion en kdm5 ... 2/2';
		raise exception '%', mensaje;
	end if;		


	-----  START : Section Added by JMM 20240516 for Extra Validations

	totalReg := 0;
	select count(*) into totalReg from keplersc.kdm5  
	where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo::int
		and c6 = folio_operacion and st_x_comprobar = 'N' 
		and fecha_comprobacion = to_date(fecha_operacion,'YYYY-MM-DD') 
		and hora_comprobacion = hora_movto and usr_comprobacion = usuario_movto;
	if totalReg = 0 then
		mensaje := 'Se encontraron Registros Discrepantes de la Operacion en kdm5 ... 2/2';
		raise exception '%', mensaje;
	end if;	

	if totalRegk5 <> totalReg then 
		mensaje := 'Existen Discrepancias entre los Registros del Documento y los Registros Procesados en kdm5 ... Paso 2/2';
		raise exception '%', mensaje;
	end if;

	-----  END : Section Added by JMM 20240516 for Extra Validations


	-- For Testing ...
	/*raise exception '%','El Documento {Cheque} sera Cancelado ...';*/

	resultado := 1;
	mensaje := ''/*folio_poliza*/;
	adicionales := '';
	return query select resultado, mensaje, adicionales;

exception
	when others then
		resultado := 0;
		mensaje := 'cheque_rollback() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;

END;
$function$
