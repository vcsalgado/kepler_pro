CREATE OR REPLACE FUNCTION keplersc.utils_transact_datachanges_xml(p_sucursal text, p_genero text, p_naturaleza text, p_grupo integer, p_tipo integer, p_folio text)
 RETURNS TABLE(xml01 xml, xml02 xml, xml03 xml, xml04 xml, xml05 xml, xml06 xml, xml07 xml, xml08 xml, xml09 xml, xml10 xml, xml11 xml, xml12 xml, xml13 xml, xml14 xml, xml15 xml, xml16 xml, xml17 xml)
 LANGUAGE plpgsql
AS $function$
declare 

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;


	--Variables de uso general
   sqlStr text;
	xmlResult xml;
   
	-- XMLs para guardar resultados de retorno de los Queries 
	xmlR01 xml;
	xmlR02 xml;
	xmlR03 xml;
	xmlR04 xml;
	xmlR05 xml;
	xmlR06 xml;
	xmlR07 xml;
	xmlR08 xml;
	xmlR09 xml;
	xmlR10 xml;
	xmlR11 xml;
	xmlR12 xml;
	xmlR13 xml;
	xmlR14 xml;
	xmlR15 xml;
	xmlR16 xml;
	xmlR17 xml;

	--Variables de definicion de documento
	sucursal_id text = '';
	genero text = '';
	naturaleza text = '';
	grupo text = '';
	tipo_clave text = '';
	folio text = '';

	clave_cteprov text = '';
	fecha_operacion text = '';
	file_name_cont text = '';	

	no_partidas int = 0;
	cantidad_unidades text = '';
	clave_producto text = '';
	importe_partida text = '';
--	fecha_movto text = '';
	tipo_movto text = '';
	hora_movto text = '';
	referencia text = '';

	--Variables de uso general 
	var_value decimal = 0.00;
	periodo_obsoleto decimal = 0.00; -- var en K75 : B10014
   sumcosto_partidas decimal = 0.00;
	decmonto_partida decimal = 0.00; -- var en K75 :  B10011
	deccantidad_partida decimal = 0.00;
   monto_partida text = '';
   cantida_partida text = '';
  
   var_suc text;
   var_prod text;
   var_exist decimal;
   var_dev decimal;
  	var_ref text;
  	var_cant decimal;
   msg_prod text;
	ptipo_compra integer;


	strValor text = '';
	intValor int = 0;
	fechValor date;
	intCont int = 0;
	decValor decimal = 0.00;
	cantidadTotal int = 0;
	numero_partida int = 0;
	no_partida_tx text;
	entradaSalida text = '';

	-- Cursor Section
	--/*
	my_record record;
   my_cursor cursor (pfolio text) for 
		select * from keplersc.kdinm where c5 = 'U' and c6 = 'D' and c7 = '9' and c8 = '1' and c9 = pfolio /*'AR23311'*/;
	--*/

   my_producto text = '';
   my_folio text = ''; 
   my_partida int = 0;
   my_cantidad decimal = 0.00;
   my_monto decimal = 0.00;
   var_i int = 0;
   sqlStrSel text = '';
    
begin 

	
	drop table if exists tmpResultados;
	create temp table tmpResultados (
		xml_01 xml,
		xml_02 xml,
		xml_03 xml,
		xml_04 xml,
		xml_05 xml,
		xml_06 xml,
		xml_07 xml,
		xml_08 xml,
		xml_09 xml,
		xml_10 xml,		
		xml_11 xml,
		xml_12 xml,
		xml_13 xml,
		xml_14 xml,
		xml_15 xml,
		xml_16 xml,
		xml_17 xml		
	);
	

	/*
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	*/

	sucursal_id = p_sucursal;
	genero = p_genero;
	naturaleza = p_naturaleza;
	grupo = p_grupo;
	tipo_clave = p_tipo;
	folio = p_folio;

	/*
	sqlStr = 'select * from keplersc.kdmm where c1='  || E'\'' || genero || E'\'' ||
		' and c2=' || E'\'' || naturaleza || E'\'' || ' and c3=' || grupo || ' and c4=' || tipo;
	
	select query_to_xml(sqlStr, true, false, '') into xmlKDMM;
	strValor := (xpath('//row/c90/text()', xmlKDMM))[1];
	if strValor is not null then
		if strValor = 'S' then
			mensajeError := 'Documento no válido';
			raise exception '%',mensajeError;			
		end if;
	end if;
	*/

	sqlStr = 'select ' || E'\'' || 'sqliov' || E'\'' || ' as table, t.* from keplersc.sqliov t where upper(t.c1) like upper(' || E'\'' || 'kfxd40%' || E'\'' ||')';
	--raise notice 'sqliov%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR02;


	sqlStr = 'select ' || E'\'' || 'kdusraccess' || E'\'' || ' as table, t.* from keplersc.kdusraccess t where t.c4 = '|| E'\'' || p_sucursal || E'\'' ||' and t.c5 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c7 = ' || E'\'' || p_grupo || E'\'' || ' and t.c8 = ' || E'\'' || p_tipo || E'\'' || ' and t.c9 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdusraccess%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR03;


	sqlStr = 'select ' || E'\'' || 'kdm1' || E'\'' || ' as table, t.* from keplersc.kdm1 t where t.c1 = '|| E'\'' || p_sucursal || E'\'' ||' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c4 = ' || E'\'' || p_grupo || E'\'' || ' and t.c5 = ' || E'\'' || p_tipo || E'\'' || ' and t.c6 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdm1%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR04;


	sqlStr = 'select ' || E'\'' || 'kdm2' || E'\'' || ' as table, t.* from keplersc.kdm2 t where t.c1 = '|| E'\'' || p_sucursal || E'\'' ||' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c4 = ' || E'\'' || p_grupo || E'\'' || ' and t.c5 = ' || E'\'' || p_tipo || E'\'' || ' and t.c6 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdm2%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR05;


	sqlStr = 'select ' || E'\'' || 'kduxe' || E'\'' || ' as table, t.* from keplersc.kduxe t where t.c1 = '|| E'\'' || p_sucursal || E'\'' ||' and t.c5 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c7 = ' || E'\'' || p_grupo || E'\'' || ' and t.c8 = ' || E'\'' || p_tipo || E'\'' || ' and t.c9 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kduxe%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR06;


	select c2, c3, c11 into clave_cteprov, referencia, fecha_operacion from keplersc.kduxe where c1 = p_sucursal and c5 = p_genero and c6 = p_naturaleza and c7 = p_grupo and c8 = p_tipo and c9 = p_folio;
	--raise notice 'clave_cteprov%', '.var ; ' || clave_cteprov;

	sqlStr = 'select ' || E'\'' || 'kduxg' || E'\'' || ' as table, t.* from keplersc.kduxg t where t.c1 = '|| E'\'' || p_sucursal || E'\'' ||' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || clave_cteprov || E'\'' || ' and (t.c4 = ' || E'\'' || p_folio || E'\'' || ' or t.c4 = ' || E'\'' || referencia || E'\'' || ') and c11 = to_date('  || E'\'' || fecha_operacion || E'\'' || ',' || E'\'' || 'YYYY-MM-DD' || E'\'' || ')'; 
	--raise notice 'kduxg%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR07;


	sqlStr = 'select ' || E'\'' || 'kdinm' || E'\'' || ' as table, t.* from keplersc.kdinm t where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c5 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c7 = ' || E'\'' || p_grupo || E'\'' || ' and t.c8 = ' || E'\'' || p_tipo || E'\'' || ' and t.c9 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdinm%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR08;


	sqlStr = 'select ' || E'\'' || 'kdink' || E'\'' || ' as table, t.* from keplersc.kdink t ' || 
		' where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 in (' || 
		'select c2 from keplersc.kdinm ' || 
		' where c1 = '|| E'\'' || p_sucursal || E'\'' || ' and c5 = ' || E'\'' || p_genero || E'\'' || 
		' and c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and c7 = ' || E'\'' || p_grupo || E'\'' || ' and c8 = ' || E'\'' || p_tipo || E'\'' || ' and c9 = ' || E'\'' || p_folio || E'\'' || ') ' 
		|| ' and t.c3 in (' || 
		'select extract(year from c3)::text from keplersc.kdinm ' || 
		' where c1 = '|| E'\'' || p_sucursal || E'\'' || ' and c5 = ' || E'\'' || p_genero || E'\'' || 
		' and c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and c7 = ' || E'\'' || p_grupo || E'\'' || ' and c8 = ' || E'\'' || p_tipo || E'\'' || ' and c9 = ' || E'\'' || p_folio || E'\'' ||') order by t.c2'; 
	--raise notice 'kdink%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR09;


	sqlStr = 'select ' || E'\'' || 'kdinl' || E'\'' || ' as table, t.* from keplersc.kdinl t ' || 
		' where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 in (' || 
		'select c2 from keplersc.kdinm ' || 
		' where c1 = '|| E'\'' || p_sucursal || E'\'' || ' and c5 = ' || E'\'' || p_genero || E'\'' || 
		' and c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and c7 = ' || E'\'' || p_grupo || E'\'' || ' and c8 = ' || E'\'' || p_tipo || E'\'' || ' and c9 = ' || E'\'' || p_folio || E'\'' ||') order by t.c2'; 
	--raise notice 'kdinl%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR10;


	sqlStr = 'select ' || E'\'' || 'kdreflastmov' || E'\'' || ' as table, t.* from keplersc.kdreflastmov t ' || 
		' where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 in (' || 
		'select c2 from keplersc.kdinm ' || 
		' where c1 = '|| E'\'' || p_sucursal || E'\'' || ' and c5 = ' || E'\'' || p_genero || E'\'' || 
		' and c6 = ' || E'\'' || p_naturaleza || E'\'' || ' and c7 = ' || E'\'' || p_grupo || E'\'' || ' and c8 = ' || E'\'' || p_tipo || E'\'' || ' and c9 = ' || E'\'' || p_folio || E'\'' ||') order by t.c2'; 
	--raise notice 'kdreflastmov%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR11;


	sqlStr = 'select ' || E'\'' || 'kdvcm' || E'\'' || ' as table, t.* from keplersc.kdvcm t where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c4 = ' || E'\'' || p_grupo || E'\'' || ' and t.c5 = ' || E'\'' || p_tipo || E'\'' || ' and t.c6 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdvcm%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR12;


	sqlStr = 'select ' || E'\'' || 'kdvobs' || E'\'' || ' as table, t.* from keplersc.kdvobs t where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c4 = ' || E'\'' || p_grupo || E'\'' || ' and t.c5 = ' || E'\'' || p_tipo || E'\'' || ' and t.c6 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdvobs%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR13;


	sqlStr = 'select ' || E'\'' || 'kdvck' || E'\'' || ' as table, t.* from keplersc.kdvck t where t.c1 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c2 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c3 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c4 = ' || E'\'' || p_grupo || E'\'' || ' and t.c5 = ' || E'\'' || p_tipo || E'\'' || ' and t.c6 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdvck%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR14;


	sqlStr = 'select ' || E'\'' || 'kdinvrcomis' || E'\'' || ' as table, t.* from keplersc.kdinvrcomis t where t.c1 = '|| E'\'' || p_sucursal || E'\'' || /*' and t.c2 = ' || E'\'' || p_genero || E'\'' ||*/ 
		' and t.c2 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c3 = ' || E'\'' || p_grupo || E'\'' || ' and t.c4 = ' || E'\'' || p_tipo || E'\'' || ' and t.c5 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdinvrcomis%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR15;

	-- * * * INI : Tratamiento TBL(s) CONT 

	select c9 into fecha_operacion from keplersc.kdm1 where c1 = p_sucursal and c2 = p_genero and c3 = p_naturaleza and c4 = p_grupo and c5 = p_tipo and c6 = p_folio;
	--raise notice 'fecha_operacion%', '.var {kdm1}; ' || fecha_operacion;

	file_name_cont := 'kdc2'; 
	fechValor := to_date(fecha_operacion,'YYYY-MM-DD');

	intValor := extract(year from fechValor) /*year(fechValor)*/;
	file_name_cont := file_name_cont || right(intValor::text,2);
	
	intValor := extract(month from fechValor) /*year(fechValor)*/;
	file_name_cont := file_name_cont || lpad(intValor::text,2,'0');
	
	--raise notice 'file_name_cont%', '.var ; ' || file_name_cont;

	sqlStr = 'select ' || E'\'' || file_name_cont || E'\'' || ' as table, t.* from keplersc.' || file_name_cont || ' t where t.c14 = '|| E'\'' || p_sucursal || E'\'' || ' and t.c15 = ' || E'\'' || p_genero || E'\'' || 
		' and t.c16 = ' || E'\'' || p_naturaleza || E'\'' || ' and t.c17 = ' || E'\'' || p_grupo || E'\'' || ' and t.c18 = ' || E'\'' || p_tipo || E'\'' || ' and t.c19 = ' || E'\'' || p_folio || E'\''; 
	--raise notice 'kdc2YYMM%', '.table ; ' || sqlStr;
	select query_to_xml(sqlStr, true, false, '') into xmlR16;

	-- * * * END : Tratamiento TBL(s) CONT


	-- VALIDACION DE TABLAS SIN REGISTROS PARA ARMAR XML INFORMANDO EL CASO DE USO ...

	if xpath_exists('//row/c1/text()', xmlR02) = false then 
		sqlStr = 'Select ' || E'\'' || 'sqliov.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR02;
	end if;

	if xpath_exists('//row/c1/text()', xmlR03) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdusraccess.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR03;
	end if;

	if xpath_exists('//row/c1/text()', xmlR04) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdm1.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR04;
	end if;

	if xpath_exists('//row/c1/text()', xmlR05) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdm2.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR05;
	end if;

	if xpath_exists('//row/c1/text()', xmlR06) = false then 
		sqlStr = 'Select ' || E'\'' || 'kduxe.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR06;
	end if;

	if xpath_exists('//row/c1/text()', xmlR07) = false then 
		sqlStr = 'Select ' || E'\'' || 'kduxg.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR07;
	end if;

	if xpath_exists('//row/c1/text()', xmlR08) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdinm.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR08;
	end if;

	if xpath_exists('//row/c1/text()', xmlR09) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdink.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR09;
	end if;

	if xpath_exists('//row/c1/text()', xmlR10) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdinl.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR10;
	end if;

	if xpath_exists('//row/c1/text()', xmlR11) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdreflastmov.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR11;
	end if;

	if xpath_exists('//row/c1/text()', xmlR12) = false then 
		sqlStr = 'Select ' || E'\'' || 'kdvcm.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR12;
	end if;

	if xpath_exists('//row/c1/text()', xmlR13) = false then 
	--	raise notice 'kdvobs%', '.table ; without rows : ' || 'Flag Exists = F ... xmlR13 ...';
		sqlStr = 'Select ' || E'\'' || 'kdvobs.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR13;
	--else
	--	raise notice 'kdvobs%', '.table ; with rows : ' || ' [OK] xmlR13 ...';
	end if;

	if xpath_exists('//row/c1/text()', xmlR14) = false then 
	--	raise notice 'kdvck%', '.table ; without rows : ' || 'Flag Exists = F ... xmlR14 ...';
		sqlStr = 'Select ' || E'\'' || 'kdvck.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR14;
	--else
	--	raise notice 'kdvck%', '.table ; with rows : ' || ' [OK] xmlR14 ...';
	end if;

	if xpath_exists('//row/c1/text()', xmlR15) = false then 
	--	raise notice 'kdinvrcomis%', '.table ; without rows : ' || 'Flag Exists = F ... xmlR15 ...';
		sqlStr = 'Select ' || E'\'' || 'kdinvrcomis.table without records ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR15;
	--else
	--	raise notice 'kdinvrcomis%', '.table ; with rows : ' || ' [OK] xmlR15 ...';
	end if;
	
	if xmlR16 is null then
		--raise notice 'NOT EXIST TBL FOR  xmlR16 ...';
		sqlStr = 'Select ' || E'\'' || coalesce(file_name_cont,'kdc2YYMM') || '.table NOT EXIST ...' || E'\'' || ' as run_info';
		select query_to_xml(sqlStr, true, false, '') into xmlR16;	
	else		
		--raise notice 'EXIST TBL FOR xmlR16 ...';
		if xpath_exists('//row/c1/text()', xmlR16) = false then 
			sqlStr = 'Select ' || E'\'' || file_name_cont || '.table without records ...' || E'\'' || ' as run_info';
			select query_to_xml(sqlStr, true, false, '') into xmlR16;
		end if;
 	end if; 

	--/*
	resultado := 1;
	mensaje := 'Queries ejecutados sin contratiempos ; ';
	adicionales := 'jmm_function_run_tbls_datachanges_xml()';
	--*/

	sqlStr = format('select %1$L as resultado, %2$L as mensaje, %3$L as adicionales',resultado,mensaje,adicionales);
	select query_to_xml(sqlStr, true, false, '') into xmlR01;

	insert into tmpResultados(xml_01,xml_02,xml_03,xml_04,xml_05,xml_06,xml_07,xml_08,xml_09,xml_10,xml_11,xml_12,xml_13,xml_14,xml_15,xml_16,xml_17) 
	values(xmlR01,xmlR02,xmlR03,xmlR04,xmlR05,xmlR06,xmlR07,xmlR08,xmlR09,xmlR10,xmlR11,xmlR12,xmlR13,xmlR14,xmlR15,xmlR16,xmlR17);
	return query select * from tmpResultados;



--/*
exception
	when others then
		resultado := 0;
		mensaje := 'jmm_function_run_tbls_datachanges_xml() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		--return query select resultado, mensaje, adicionales;
		
		drop table if exists tmpResultados;
	   create temp table tmpResultados (
			xml_01 xml,
			xml_02 xml,
			xml_03 xml,
			xml_04 xml,
			xml_05 xml,
			xml_06 xml,
			xml_07 xml,
			xml_08 xml,
			xml_09 xml,
			xml_10 xml,		
			xml_11 xml,
			xml_12 xml,
			xml_13 xml,
			xml_14 xml,
			xml_15 xml,
			xml_16 xml,
			xml_17 xml	
		);
		
		--/*
		sqlStr = format('select %1$L as resultado, %2$L as mensaje, %3$L as adicionales',resultado,mensaje,adicionales);
	   --select query_to_xml(sqlStr, true, false, '') into xmlResult;	
	   --return xmlResult;
		
	   select query_to_xml(sqlStr, true, false, '') into xmlR01;
	   --return query select xmlR01,xmlR02,xmlR03,xmlR04,xmlR05,xmlR06,xmlR07;
		insert into tmpResultados(xml_01,xml_02,xml_03,xml_04,xml_05,xml_06,xml_07,xml_08,xml_09,xml_10,xml_11,xml_12,xml_13,xml_14,xml_15,xml_16,xml_17) 
		values(xmlR01,xmlR02,xmlR03,xmlR04,xmlR05,xmlR06,xmlR07,xmlR08,xmlR09,xmlR10,xmlR11,xmlR12,xmlR13,xmlR14,xmlR15,xmlR16,xmlR17);
		return query select * from tmpResultados;
	   --*/
--*/	
end;
$function$
