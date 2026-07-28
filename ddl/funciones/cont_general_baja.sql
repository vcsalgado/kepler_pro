CREATE OR REPLACE FUNCTION keplersc.cont_general_baja(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza baja general de contabilidad
--Autor: Miriam Santana
--Fecha: 23/08/2022
--Bitacora de cambios
--08/09/2025 Miriam Santana: Obtener el movto inicial para consultar la tabla de la contrapoliza para movtos que cancela el inicial c43=C
--09/06/2026 Miriam Santana: Eliminar el registro de kdsunicosto

	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	fecha_operacion text; --yyyy-mm-dd
	fecha_movto_kdc date;	--MSS 08092025 Cambie a date para asignar fecha de movto inicial
	nombre_cteprov text;
	referencia text;
	anio_contable text ='';
	fecha_kdc text;

	--variables kdc
	monto_kdc decimal = 0.00;
	tipo_asiento_kdc text = '';
	tipo_asiento_nvo text = '';
	accion_poliza_kdc text = '';
	folio_poliza_kdc int = 0;
	numero_partida_poliza_kdc int = 0;
	cuenta_kdc text = '';
		
	--Variables kdmm
	tipo_poliza_kdmm text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	anio_en_curso text;
	mes_en_curso text;
	tabla_polizas text = '';
	strValor text;
	strValorB text;
	strMonto text;
	mensajeError text;
	varcont xml;
	expSql text='';
	folio_id text = '';
	total_registros int = 0;
	rec record;
	udia_mes_anterior date;
	pdia_mes_actual date;

	regs int;
	
begin
	
	--Trasaccion
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//document/k_fecha/text()', dataxml))[1];
	referencia := (xpath('//document/k_refer/text()',dataxml))[1];
	fecha_movto_kdc := (xpath('//row/c9/text()',xmlkdm1))[1];
	
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlkdmm))[1]::text;


	-- Section Code Commented by JMM 20240801 to Fix Date Usages , dealed with VCSS  
	/* 
	--raise exception '%' , fecha_movto_kdc;
	--Obtener nombres de tablas y campos del anio-mes contable en curso
	anio_en_curso := substring(fecha_movto_kdc,3,2);
	mes_en_curso := substring(fecha_movto_kdc,6,2);
	accion_poliza_kdc := 'NUEVAPOLIZA';

	--Obtener fecha para el movimiento
	select date_trunc('month', fecha_operacion::date) -'1sec' ::interval into udia_mes_anterior;
	select date_trunc('month', fecha_operacion::date) into pdia_mes_actual;
	
	if fecha_operacion::date<pdia_mes_actual then
		fecha_operacion=udia_mes_anterior::text;
		--TO DO: Validar que no este cerrado el mes, si no fecha_operacion= current_date::text;
	else
		fecha_operacion=current_date::text;
	end if;
	*/


	-- Section Code Adapted by JMM 20240801

	if xpath_exists('//document/movimiento/fecha/text()', dataxml) = true then 
		fecha_operacion := coalesce((xpath('//document/movimiento/fecha/text()', dataxml))[1]::text,'1800-01-01 00:00:00')::text;
		if extract(year from fecha_operacion::date) = 1800 then
			fecha_operacion := current_date::text;
		end if;
	else
		fecha_operacion := current_date::text;
	end if;

	accion_poliza_kdc := 'NUEVAPOLIZA';
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);

	/*
	raise exception '%', ' '
		|| ' | ' || ' ' || ' | ' || 'Fecha Operacion : ' || fecha_operacion 
		|| ' | ' || ' ' || ' | ' || 'Anio_en_curso : ' || anio_en_curso 
		|| ' | ' || ' ' || ' | ' || 'Mes_en_curso : ' || mes_en_curso ;
	--*/


	--Obtener el folio de la poliza
	--Formato fecha operacion YYYY-MM-DD, ejemplo: 2022-01-07
	folio_id := 'POLIZA' || tipo_poliza_kdmm || substring(fecha_operacion, 3, 2) || substring(fecha_operacion, 6, 2);
	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_id);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza_kdc := mensaje::int;

	--Polizas
	tabla_polizas := 'keplersc.kdc2' || anio_en_curso || mes_en_curso;

	--Added by JMM 20240821 to detect if policy to revert exist 
	--/*
	expSql = format('select count(distinct(c1)) from %1$s where c14=%2$L and c15=%3$L and c16=%4$L and c17=%5$s and c18=%6$s and c19=%7$L',
			tabla_polizas,sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion);	
	regs := 0;
	execute expSql into regs;
	regs := coalesce(regs,-1);
	if regs <= 0 then
		--MSS 08092025 Busca la fecha del movimiento inicial para buscar la contrapoliza
		select c9 into fecha_movto_kdc from keplersc.kdm1 where c1=sucursal_id and c2=genero and c3=naturaleza and c4=grupo::integer and c5=tipo_clave::integer and c6=folio_operacion;
		anio_en_curso := substring(fecha_movto_kdc::text,3,2);
		mes_en_curso := substring(fecha_movto_kdc::text,6,2);
		tabla_polizas := 'keplersc.kdc2' || anio_en_curso || mes_en_curso;
		--raise notice 'g:% n:% g:% t:% fol:% anio:% mes:% tabla:%',genero,naturaleza,grupo,tipo_clave,folio_operacion,anio_en_curso,mes_en_curso,tabla_poliza_doc;
		--Busca si existe la contrapóliza
		expSql = format('select count(distinct(c1)) from %1$s where c14=%2$L and c15=%3$L and c16=%4$L and c17=%5$s and c18=%6$s and c19=%7$L',
			tabla_polizas,sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion);	
		regs := 0;
		execute expSql into regs;
		regs := coalesce(regs,-1);
		if regs <= 0 then
			raise exception '%', 'No se encontro la Poliza del Documento Origen para la Contra-Poliza ...';
		end if;
	end if;
	--*/



	expSql= format('select c2 as fecha_kdc,c3 as cuenta_kdc,c4 as tipo_asiento_kdc,c5 as monto_kdc,
			c6 as nombre_cteprov,c7 as referencia,c8 as tipo_poliza_kdmm,c10 as numero_partida_poliza_kdc
			  from %1$s where c14=%2$L and c15=%3$L and c16=%4$L and c17=%5$s and c18=%6$s and c19=%7$L',
			tabla_polizas,sucursal_id,genero,naturaleza,grupo,tipo_clave,folio_operacion);	
				
	--Generar nueva poliza por cada partida
	for rec in execute expSql 
	loop
		 if rec.tipo_asiento_kdc = 'C' then --Cargo
			tipo_asiento_nvo = 'A';
		else
			tipo_asiento_nvo = 'C';
		end if;	
		strValorB := 'BAJA: '||rec.nombre_cteprov;
		select xmlforest(fecha_operacion as fecha, rec.cuenta_kdc as cuenta, tipo_asiento_nvo as tipo_asiento, 
			rec.monto_kdc as monto, strValorB as descrip, rec.referencia as refer, 
			rec.tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
			sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
			accion_poliza_kdc as accion_poliza,folio_poliza_kdc as folio_poliza,
			rec.numero_partida_poliza_kdc as numero_partida)::text into strValor;					  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		varcont := strValor::xml;
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
	end loop;

	--MSS 09062026 Eliminar registro de KDSUNICOSTO
	delete from keplersc.kdsunicosto 
		where c1 = sucursal_id and c2 = genero and c3 = naturaleza and c4 = grupo::int and c5 = tipo_clave::int and c6 = folio_operacion;
	
	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'cont_general_baja() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
