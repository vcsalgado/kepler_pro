CREATE OR REPLACE FUNCTION keplersc.cont_general_alta(dataxml xml, xmlkdm1 xml, xmlkdmm xml, folio_operacion text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Variables para xml 
	sucursal_id text;
	genero text;
	naturaleza text;
	grupo text;
	tipo_clave text;
	fecha_operacion text; --yyyy-mm-dd
	usuario_movto text;
	fecha_movto text;
	hora_movto text; 
	nombre_cteprov text;
	monto_descuento decimal = 0.00;
	monto_iva decimal = 0.00;
	monto_ieps decimal = 0.00;
	monto_total decimal = 0.00;
	monto_sin_iva decimal = 0.00;
	referencia text = '';
	anio_contable text ='';
	anio_en_curso text = '';
	mes_en_curso text = '';
	tabla_polizas text = '';
	monto_cargo decimal = 0.00;
	monto_abono decimal = 0.00;
	monto_isan_ieps decimal = 0.00;
	monto_extra_1 decimal = 0.00;
	monto_extra_2 decimal = 0.00;
	monto_extra_3 decimal = 0.00;
	monto_extra_4 decimal = 0.00;
	monto_extra_5 decimal = 0.00;
	monto_extra_6 decimal = 0.00;
	monto_extra_7 decimal = 0.00;
	monto_extra_8 decimal = 0.00;
	monto_extra_9 decimal = 0.00;
	monto_extra_10 decimal = 0.00;
	monto_anticipos decimal = 0.00;
	costo decimal = 0.00;
	monto_iva_anticipo decimal = 0.00;
	tipo_asiento text = '';
	accion_poliza text = '';
	folio_poliza int = 0;
	numero_partida_poliza int = 0;
	uen text = '';

	cuenta text = '';
	cuenta_cargo text = '';
	cuenta_abono text = '';
	cuenta_iva text = '';
	cuenta_iva_cmp_isan text = '';
	cuenta_cargo_iva_anticipo text = '';
	cuenta_abono_iva_anticipo text = '';
	cuenta_cargo_anticipo text = '';
	cuenta_abono_anticipo text = '';
	cuenta_cargo_costo text = '';
	cuenta_abono_costo text = '';
	cuenta_extra_1 text = ''; 
	cuenta_extra_2 text = '';
	cuenta_extra_3 text = '';
	cuenta_extra_4 text = '';
	cuenta_extra_5 text = '';
	cuenta_extra_6 text = '';
	cuenta_extra_7 text = '';
	cuenta_extra_8 text = '';	
	cuenta_extra_9 text = '';
	cuenta_extra_10 text = '';
	descripcion_partida text = '';
	descripcion_cuenta text = '';
	monto_partida decimal = 0.00;


	/* Added by JMM 20240619 to 20240701 for CM - Retenciones */
	monto_iva_retencion decimal = 0.00; -- 20240619
	cuenta_iva_retencion text = ''; -- 20240619
	flag_gastos text = ''; -- 20240701
	

	--Variables autos
	v_entradasenunidades decimal = 0.00;
	v_salidasenunidades decimal = 0.00;
	v_entradasenmonto decimal = 0.00;
	v_salidasenmonto decimal = 0.00;
	v_ultimocosto decimal = 0.00;
	v_B8056_costo decimal = 0.00;
	v_inventario text = '';

	--Variables kdmm
	cuenta_contable_kdmm text = '';
	cuenta_contable_abono_kdmm text = '';
	porcentaje_iva_kdmm decimal = 16.00;
	tipo_poliza_kdmm text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	strValor text;
	intValor int;
	strValorB text;
	strValorC text;
	strMonto text;
	mensajeError text;
	varcont xml;
	expSql text='';
	folio_id text = '';
	total_registros int = 0;
	cuentas_validas int = 0;

	partidasStr text = '';
	partidasXml xml;

	tabla_cuentas text = '';
	cont int = 0;
	adicionalesStr text= '';
	xmlCuentas xml;
	funCuenta text = '';
begin
--Descripcion: Programa princpal para el registro contable de movimientos.
--Las cuetas se obtienen de la configuraci�n en la tabla kdmm y los montos de los conceptos
--se toman de la tabla kdm1, en la que el movimiento se debe haber registrado de forma previa
--Las tablas kdm1 y kdmm entran como parametros con el registro correspondiente para la operacion
--Autor: Victor Salgado
--Fecha: 01/01/2022

	--Crear tabla temporal donde se acumularan las partidas de la poliza
	drop table if exists tmpkdc2;
	create temp table tmpkdc2 as select * from keplersc.kdc2;
	alter table tmpkdc2 add column desc_cuenta varchar(50); --
	alter table tmpkdc2 add column cuenta_validacion varchar(80);

	--Trasaccion
	sucursal_id := (xpath('//row/c1/text()', xmlkdm1))[1]; --(xpath('//document/k_sucn/r1/text()', dataxml))[1];
	genero := (xpath('//row/c2/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r1/text()', dataxml))[1];
	naturaleza := (xpath('//row/c3/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r2/text()', dataxml))[1];
	grupo := (xpath('//row/c4/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r3/text()', dataxml))[1];
	tipo_clave := (xpath('//row/c5/text()', xmlkdm1))[1]; --(xpath('//document/k_tipon/r4/text()', dataxml))[1];
	fecha_operacion := (xpath('//row/c9/text()', xmlkdm1))[1]; --(xpath('//document/k_fecha/text()', dataxml))[1];
	referencia := (xpath('//row/c11/text()', xmlkdm1))[1]; --(xpath('//document/k_refer/text()',dataxml))[1];
	strMonto := coalesce((xpath('//row/c13/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_descuento:=strMonto::decimal;
	strMonto := coalesce((xpath('//row/c14/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];	
	monto_iva := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_iva/text()',dataxml))[1];			
	monto_ieps := strMonto::decimal;
	strMonto := coalesce((xpath('//row/c16/text()', xmlkdm1))[1]::text,'0.00')::text; --(xpath('//document/k_monto/text()',dataxml))[1];
	monto_total := strMonto::decimal;
	anio_contable := (xpath('//document/ambiente/anio_contable/text()',dataxml))[1];
	
	monto_sin_iva = monto_total - monto_iva;
	--Asignar monto_extra_1..10 de la KDM1.C51..c60
	strMonto := coalesce((xpath('//row/c51/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_1 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c52/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_2 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c53/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_3 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c54/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_4 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c55/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_5 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c56/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_6 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c57/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_7 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c58/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_8 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c59/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_9 := StrMonto::decimal;
	strMonto := coalesce((xpath('//row/c60/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_extra_10 := StrMonto::decimal;
	
	uen=coalesce((xpath('//row/c95/text()', xmlKDMM))[1],'')::text;	--MSS 17102024 Obtener la uen de la KDMM.c95
	if uen='' then
		raise exception 'Falta la uen en la configuracion del movimiento';
	end if;
	if uen='V' then
		uen:='VEN';
	end if;
	if uen='R' then
		uen:='REF';
	end if;
	if uen='S' then
		uen:='SER';
	end if;

--raise notice 'uen:% ', uen;
	anio_en_curso := substring(fecha_operacion,3,2);
	mes_en_curso := substring(fecha_operacion,6,2);
	
	--tabla cuentas
	tabla_cuentas := 'keplersc.kdc1' || anio_en_curso;
	--Documento KDMM
	strValor := (xpath('//row/c16/text()', xmlKDMM))[1]::text;
	if strValor is not null and strValor <> '0' and strValor <> 'N' then
		porcentaje_iva_kdmm = strValor::decimal;
	end if;
 	
	tipo_poliza_kdmm := (xpath('//row/c18/text()', xmlKDMM))[1]::text;

	--raise exception '%,%,%,%' , cuenta_contable_cargo_kdmm, cuenta_contable_abono_kdmm, tipo_poliza_kdmm, monto_total;

	strMonto := coalesce((xpath('//row/c15/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_isan_ieps := StrMonto::decimal;

	--Added by JMM 20240619 ... Monto Retencion IVA 
	strMonto := coalesce((xpath('//row/c23/text()', xmlkdm1))[1]::text,'0.00')::text;
	monto_iva_retencion := StrMonto::decimal;

	--Added by JMM 20240701 ... TAG para uso de Retenciones (SCH - Gastos / Compras)
	flag_gastos = '';
	if xpath_exists('//document/ambiente/schema/text()', dataxml) = true /*false*/ then 
		flag_gastos := coalesce((xpath('//document/ambiente/schema/text()',dataxml))[1]::text,'')::text;
	end if;
	
	
--INICIO Cuenta cargo, campo c19 kdmm
	cuenta_contable_kdmm := (xpath('//row/c19/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
		if upper(cuenta_contable_kdmm) = 'PAGO_OPERARIOS' then
			funCuenta:='cont_pago_operarios';
		end if;
	end if;

	if funCuenta = '' then	
		if naturaleza = 'D'  then
			monto_cargo := monto_total::decimal;
		else --Naturaleza <> 'D'
			strValor:=coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,''); --Divide la cta de IVA en cuentas complemetarias
			
			--New Condition Added by JMM 20240701, Manejo de Retenciones (con un TAG)
			if upper(flag_gastos) = 'CXP_CM_RETENCIONES' then 

				--Retencion Comentada porque No aplica para el Gpo de Docs Administrados con este TAG 
				if strValor <> 'S' then --Divide IVA en ctas complementarias
					--Adapted by JMM 20240702 (Retenciones se Suman al Subtotal)
					monto_cargo := monto_total - monto_iva /* - monto_isan_ieps*/ + monto_isan_ieps + monto_iva_retencion;
				else --CUENTA COMPLEMENTARIA DE IVA	
					monto_cargo := monto_total /*- monto_isan_ieps*/;
				end if;	
			
				--raise exception 'Monto Total%', monto_cargo;
			
			else
			
				--Codigo Original, Market-up by JMM 20240701
				if strValor <> 'S' then --Divide IVA en ctas complementarias
					monto_cargo := monto_total - monto_iva - monto_isan_ieps;
				else --CUENTA COMPLEMENTARIA DE IVA	
					monto_cargo := monto_total - monto_isan_ieps;
				end if;	
			
			end if;
		
			strValor:=coalesce((xpath('//row/c66/text()', xmlKDMM))[1]::text,''); --Ventas Contado
			strValorB:=coalesce((xpath('//row/c52/text()', xmlKDMM))[1]::text,''); --Maneja backorder
			if strValor <> 'S' and strValorB <> 'S' then
				monto_cargo = monto_cargo - 
					(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
					monto_extra_6 + monto_extra_7);
			end if;
		end if;
		select '<varcont><n5>25</n5><n6>19</n6></varcont>'::xml into varcont; --26 Campo a�adir/ 19 cta cargo
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		--En datos adicionales viene la cuenta calculada y el nombre del cliente/proveedor separado por |
		cuenta_cargo := split_part(adicionales, '|', 1);			
		descripcion_partida := split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);	
--raise exception 'Cta % Monto %',cuenta_cargo, monto_cargo;
		if cuenta_cargo is not null and cuenta_cargo <> '' and monto_cargo <> 0 then
			tipo_asiento := 'C';
			--c6 descripcion poliza, c7 Referencia,desc_cuenta,
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_cargo,tipo_asiento,monto_cargo,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));
			--cta,tipo_asiento,monto,descripcion,referencia,
		end if;
	else
		strValorB :=xmlKDMM::text;
		if funCuenta = 'cont_pago_operarios' then
			strValor:=dataxml::text;
			strValorC:= folio_operacion;
		else
			strValor:=xmlKDM1::text;
			strValorC := 'c19';
		
		end if;
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,strValorC,strValor,strValorB);
		execute expSql into xmlCuentas;	
	
		--raise notice '19 expSql %',expSql;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
	
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;			
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));
			end loop;
		else
			raise exception '%', strValor;
		end if;
	end if;
--FIN Cuenta Cargo
  --raise notice 'fin cuenta 19';
--INICIO Cuenta abono, campo c20 kdmm
	--Obtencion de la cuenta de abono
	cuenta_contable_kdmm := (xpath('//row/c20/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
--raise notice 'Funcion %',funCuenta;
	if funCuenta = '' then	
		if naturaleza = 'D'  then
			strValor:=coalesce((xpath('//row/c30/text()', xmlKDMM))[1]::text,''); --Divide la cta de IVA en cuentas complemetarias
			
			--New Condition Added by JMM 20240701, Manejo de Retenciones (con un TAG)
			if upper(flag_gastos) = 'CXP_CM_RETENCIONES' then
			
				--Retencion Comentada porque No aplica para el Gpo de Docs Administrados con este TAG, para Homogar BAJAS o Contramovimientos
				if strValor <> 'S' then --Divide IVA en ctas complementarias
					--Adapted by JMM 20240702 (Retenciones se Suman al Subtotal)
					monto_abono := monto_total - monto_iva /* - monto_isan_ieps*/ + monto_isan_ieps + monto_iva_retencion;
				else --CUENTA COMPLEMENTARIA DE IVA
					monto_abono = monto_total /* - monto_isan_ieps*/;
				end if;

			else 
			
				--Codigo Original, Market-up by JMM 20240701
				if strValor <> 'S' then --Divide IVA en ctas complementarias
					monto_abono := monto_total - monto_iva - monto_isan_ieps;
				else --CUENTA COMPLEMENTARIA DE IVA
					monto_abono = monto_total - monto_isan_ieps;
				end if;
			
			end if;
		
			strValor:=coalesce((xpath('//row/c66/text()', xmlKDMM))[1]::text,''); --Ventas Contado
			strValorB:=coalesce((xpath('//row/c52/text()', xmlKDMM))[1]::text,''); --Maneja backorder
			if strValor <> 'S' and strValorB <> 'S' then
				monto_abono = monto_abono - 
					(monto_extra_1 + monto_extra_2 + monto_extra_3 + monto_extra_4 + monto_extra_5 +
					monto_extra_6 + monto_extra_7);
			end if;
		else --Naturaleza <> 'D'
			monto_abono := monto_total::decimal;
		end if;
		select '<varcont><n5>26</n5><n6>20</n6></varcont>'::xml into varcont; --26 Campo a�adir/ 20 cta abono
		select * into resultado, mensaje, adicionales from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);
--raise notice 'Cuenta %, monto %',cuenta_abono, monto_abono;
		cuenta_abono := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_abono is not null and cuenta_abono <> '' and monto_abono <> 0 then
			tipo_asiento := 'A';
			--c6 descripcion poliza, c7 Referencia,desc_cuenta,			
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_abono,tipo_asiento,monto_abono,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));		
		end if;
	else		
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c20',strValor,strValorB);
		execute expSql into xmlCuentas;
	
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;						
				insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	

--FIN Cuenta Abono
--raise notice 'fin cuenta 20';
--INICIO Creacion IVA
	cuenta_contable_kdmm := (xpath('//row/c21/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	
	if funCuenta = '' then		
		--Monto iva obtenido en xmlkdm1, campo 14, variable monto_iva
		select '<varcont><n5>0</n5><n6>21</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
--raise exception 'Adicionales: %',adicionales;
		cuenta_iva := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_iva is not null and cuenta_iva <> '' and monto_iva <> 0 then
			if naturaleza = 'D' then
				tipo_asiento = 'A';
			else
				tipo_asiento = 'C';
			end if;
			
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_iva,tipo_asiento,monto_iva,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));			
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c21',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;					
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,left(descripcion_partida,40),referencia,left(descripcion_cuenta,50));
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta IVA

--INICIO Cuenta IEPS
	--monto isan_ieps, viene en xmlkdm1 campo 15, variable monto_isan_ieps
	cuenta_contable_kdmm := (xpath('//row/c22/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
--	raise exception 'entro ieps';
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then	
		strValor:=(xpath('//row/c30/text()', xmlKDMM))[1]::text; --Divide la cta de IVA en cuentas complemetarias
		strValor=coalesce(strValor,'');	
		if strValor <> 'S' then
			monto_isan_ieps := monto_isan_ieps;		
		else
			monto_isan_ieps := monto_iva;
		end if;
		select '<varcont><n5>0</n5><n6>22</n6></varcont>'::xml into varcont; --22 cta contable ieps
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_iva_cmp_isan := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3); 
--raise notice 'adicionales % ,% ',adicionales,monto_isan_ieps; 
		--cuenta_iva_cmp_isan	-->ISAN O IVA COMPLEMENTARIO
		if cuenta_iva_cmp_isan is not null and cuenta_iva_cmp_isan <> '' and monto_isan_ieps <> 0 then	
			--CONT(T,W9,B8003,B8090,B8053,B8020,W11,M18,"","","","","",W1...W6,B8095)	
			if naturaleza = 'D' then
				tipo_asiento = 'A';
			else
				tipo_asiento = 'C';
			end if;	
		
			-- Uncommented 20240702 by JMM validated by VCSS ... using specific TAG
			--New Condition Added by JMM 20240702, Manejo de Retenciones (con un TAG)
			if upper(flag_gastos) = 'CXP_CM_RETENCIONES' then 
				strValor:=(xpath('//row/c30/text()', xmlKDMM))[1]::text;
				strValor=coalesce(strValor,'');	
				if strValor <> 'S' then
					if tipo_asiento ='C' then
						tipo_asiento := 'A';
					else 
						tipo_asiento := 'C';
					end if;
				end if;
			else
				strValor:=(xpath('//row/c30/text()', xmlKDMM))[1]::text;
				strValor=coalesce(strValor,'');	
				if strValor = 'S' then
					if tipo_asiento ='C' then
						tipo_asiento := 'A';
					else 
						tipo_asiento := 'C';
					end if;
				end if;
			end if;
			
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_iva_cmp_isan,tipo_asiento,monto_isan_ieps,descripcion_partida,referencia,descripcion_partida);			
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c22',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;				
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta IEPS



----- START : SECTION RETENCION IVA , Added by JMM 20240619 

--INICIO Cuenta IVA Retencion 
	--monto iva_retencion, viene en xmlkdm1 campo 23, variable monto_iva_retencion
	cuenta_contable_kdmm := (xpath('//row/c64/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
--	raise exception 'entro ieps';
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then	
		select '<varcont><n5>0</n5><n6>64</n6></varcont>'::xml into varcont; --64 cta contable iva retencion
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_iva_retencion := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3); 
--raise notice 'adicionales % ,% ',adicionales,monto_iva_retencion; 
		--cuenta_iva_retencion	-->ISAN O IVA COMPLEMENTARIO
		if cuenta_iva_retencion is not null and cuenta_iva_retencion <> '' and monto_iva_retencion <> 0 then	
			--CONT(T,W9,B8003,B8090,B8053,B8020,W11,M18,"","","","","",W1...W6,B8095)	
			if naturaleza = 'D' then
				tipo_asiento = 'A';
			else
				tipo_asiento = 'C';
			end if;	
		
			-- Uncommented 20240702 by JMM validated by VCSS ... using specific TAG
			--New Condition Added by JMM 20240702, Manejo de Retenciones (con un TAG) ... Homologado con IEPS (Retencion ISR para estos casos)
			if upper(flag_gastos) = 'CXP_CM_RETENCIONES' then 
				strValor:=(xpath('//row/c30/text()', xmlKDMM))[1]::text;
				strValor=coalesce(strValor,'');	
				if strValor <> 'S' then
					if tipo_asiento ='C' then
						tipo_asiento := 'A';
					else 
						tipo_asiento := 'C';
					end if;
				end if;
			end if;
			
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_iva_retencion,tipo_asiento,monto_iva_retencion,descripcion_partida,referencia,descripcion_partida);			
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c64',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;				
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta IVA Retencion 

----- END : SECTION RETENCION IVA , Added by JMM 20240619 



--INICIO Cuenta Cargo Anticipo, Extra 1 , kdmm.c23
	cuenta_contable_kdmm := (xpath('//row/c23/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		monto_anticipos := 0;
		strValor := (xpath('//row/c49/text()', xmlKDM1))[1];
		if strValor is not null then
			monto_anticipos := strValor::decimal;	
		end if;
		select '<varcont><n5>54</n5><n6>23</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_cargo_anticipo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_cargo_anticipo is not null and cuenta_cargo_anticipo <> '' and monto_anticipos <> 0 then
	    	tipo_asiento = 'C';
			
	    insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_cargo_anticipo,tipo_asiento,monto_anticipos,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c23',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;				
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Creacion Cuenta Cargo Anticipo

--INICIO Cuenta Abono Anticipo, Extra 2 , kdmm.c24
	cuenta_contable_kdmm := (xpath('//row/c24/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then	
		monto_anticipos := 0;
		strValor := (xpath('//row/c49/text()', xmlKDM1))[1];
		if strValor is not null then
			monto_anticipos := strValor::decimal;	
		end if;
	
		select '<varcont><n5>55</n5><n6>24</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_abono_anticipo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_abono_anticipo is not null and cuenta_abono_anticipo <> '' and monto_anticipos <> 0 then
	    	tipo_asiento = 'A';
	
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_abono_anticipo,tipo_asiento,monto_anticipos,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c24',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;				
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
			 	
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Creacion Cuenta Abono Anticipo

--INICIO Cuenta Cargo IVA Anticipo,  kdmm.c72
	cuenta_contable_kdmm := (xpath('//row/c72/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		monto_anticipos := 0;
		strValor := (xpath('//row/c49/text()', xmlKDM1))[1];
		if strValor is not null then
			monto_anticipos := strValor::decimal;	
		end if;
	    monto_iva_anticipo := monto_anticipos*(1-(1/(1+porcentaje_iva_kdmm/100)));
		select '<varcont><n5>0</n5><n6>72</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_cargo_iva_anticipo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_cargo_iva_anticipo is not null and cuenta_cargo_iva_anticipo <> '' and monto_iva_anticipo <> 0 then
	    	tipo_asiento = 'C';
	    
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_cargo_iva_anticipo,tipo_asiento,monto_iva_anticipo,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c72',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;				
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Creacion Cuenta Cargo IVA Anticipo


--INICIO Cuenta Abono IVA Anticipo, Extra 1 , kdmm.c73
	cuenta_contable_kdmm := (xpath('//row/c73/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		monto_anticipos := 0;
		strValor := (xpath('//row/c49/text()', xmlKDM1))[1];
		if strValor is not null then
			monto_anticipos := strValor::decimal;	
		end if;
	    monto_iva_anticipo := monto_anticipos*(1-(1/(1+porcentaje_iva_kdmm/100)));
		select '<varcont><n5>0</n5><n6>73</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_abono_iva_anticipo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_abono_iva_anticipo is not null and cuenta_abono_iva_anticipo <> '' and monto_iva_anticipo <> 0 then
	    	tipo_asiento = 'A';
	    
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_abono_iva_anticipo,tipo_asiento,monto_iva_anticipo,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c73',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Creacion Cuenta Abono IVA Anticipo


--INICIO Cuenta Cargo Costo, Extra 3 , kdmm.c56 Campo a�adir, kdmm.c34, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c34/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		costo := monto_sin_iva::decimal; --Por defecto, el costo es el importe sin iva
		if uen='VEN' then --Racalcular costo para Autos
			v_inventario:= (xpath('//row/c100/text()',xmlKDM1))[1];
raise notice 'v_inventario:% ', v_inventario;		
			if (select count(*) from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario) > 0 then 
				select c3,c4,c5,c6,c8 into v_entradasenunidades,v_salidasenunidades,v_entradasenmonto,v_salidasenmonto,v_ultimocosto from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario;		
				if (v_entradasenunidades - v_salidasenunidades) = 0 then 
					v_B8056_costo = v_ultimocosto;
				else	
					v_B8056_costo = (v_entradasenmonto - v_salidasenmonto) / (v_entradasenunidades-v_salidasenunidades);
				end if;	
				costo := v_B8056_costo;
			end if;
		end if;
raise notice 'costo:% ', costo;
		if uen='REF' or uen ='SER' then
			costo:=0;
			select coalesce(sum(coalesce(c12,0)),0) into costo from keplersc.kdinm where c1=sucursal_id and c5=genero 
				and c6=naturaleza and c7=grupo::int and c8=tipo_clave::int and c9=folio_operacion;
			if costo=0 then
				costo := monto_sin_iva::decimal; --Por defecto, el costo es el importe sin iva
			end if;
		end if;
		select '<varcont><n5>56</n5><n6>34</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_cargo_costo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_cargo_costo is not null and cuenta_cargo_costo <> '' and costo <> 0 then
	    	tipo_asiento = 'C';
	    
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_cargo_costo,tipo_asiento,costo,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c34',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta Cargo Costo


--INICIO Cuenta Abono Costo, Extra 4 , kdmm.c57 Campo a�adir, kdmm.c35, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c35/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		costo := monto_sin_iva::decimal;
		if uen='VEN' then --Racalcular costo para Autos
			v_inventario:= (xpath('//row/c100/text()',xmlKDM1))[1];			
			if (select count(*) from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario) > 0 then 
				select c3,c4,c5,c6,c8 into v_entradasenunidades,v_salidasenunidades,v_entradasenmonto,v_salidasenmonto,v_ultimocosto from keplersc.KDLINV where c1 = sucursal_id and c2 = v_inventario;		
				if (v_entradasenunidades - v_salidasenunidades) = 0 then 
					v_B8056_costo = v_ultimocosto;
				else	
					v_B8056_costo = (v_entradasenmonto - v_salidasenmonto) / (v_entradasenunidades-v_salidasenunidades);
				end if;	
				costo := v_B8056_costo;
			end if;			
		end if;	
		if uen='REF' or uen ='SER' then
			costo:=0;
			select coalesce(sum(coalesce(c12,0)),0) into costo from keplersc.kdinm where c1=sucursal_id and c5=genero 
				and c6=naturaleza and c7=grupo::int and c8=tipo_clave::int and c9=folio_operacion;
			if costo=0 then
				costo := monto_sin_iva::decimal; --Por defecto, el costo es el importe sin iva
			end if;
		end if;	
		select '<varcont><n5>57</n5><n6>35</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_abono_costo := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_abono_costo is not null and cuenta_abono_costo <> '' and costo <> 0 then
	    	tipo_asiento = 'A';
	    
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_abono_costo,tipo_asiento,costo,descripcion_partida,referencia,descripcion_cuenta);		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c35',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;
--FIN Cuenta Abono Costo

-- Movido aqui por (antes de c36) el 20221207 2355 JMM
-- Aplica en Librerias K75 a REF y AUT 
if naturaleza = 'D' then
	tipo_asiento = 'A';
else
	tipo_asiento = 'C';
end if;	


--INICIO Cuenta extra 1, a�adir kdmm.58, kdmm.c36, cuenta extra
	cuenta_contable_kdmm := (xpath('//row/c36/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then		
		select '<varcont><n5>58</n5><n6>36</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_1 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_1 is not null and cuenta_extra_1 <> '' and monto_extra_1 <> 0 then
	    	
			--Comentado el 20221207 2350 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
			--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090
	
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_1,tipo_asiento,monto_extra_1,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c36',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 1

-- Movido para antes de c36 el 20221207 2355 JMM
/*
-- A partir de la cuenta extra 6 el calculo del tipo de asiento es en base a esta condicion 
-- Aplica en Librerias K75 a REF y AUT 
if naturaleza = 'D' then
	tipo_asiento = 'A';
else
	tipo_asiento = 'C';
end if;	
*/

--INICIO Cuenta extra 2, a�adir kdmm.59, kdmm.c37, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c37/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then	
		select '<varcont><n5>59</n5><n6>37</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_2 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_2 is not null and cuenta_extra_2 <> '' and monto_extra_2 <> 0 then
		
			--Comentado el 20221207 2355 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
	    	--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090
	    	
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_2,tipo_asiento,monto_extra_2,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c37',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 2


--INICIO Cuenta extra 3, a�adir kdmm.60, kdmm.c38, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c38/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		select '<varcont><n5>60</n5><n6>38</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_3 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_3 is not null and cuenta_extra_3 <> '' and monto_extra_3 <> 0 then
		
			--Comentado el 20221207 2355 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
	    	--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090
		
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_3,tipo_asiento,monto_extra_3,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c38',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
						
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 3


--INICIO Cuenta extra 4, a�adir kdmm.61, kdmm.c39, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c39/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		select '<varcont><n5>61</n5><n6>39</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_4 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_4 is not null and cuenta_extra_4 <> '' and monto_extra_4 <> 0 then
		
			-- Codigo Incluido 20221206 1735 por JMM, Comentado el 20221207 2355
			/*
			if naturaleza = 'D' then
				tipo_asiento = 'A';
			else
				tipo_asiento = 'C';
			end if;	
			*/
		
			--Comentado el 20221206 1735 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
	    	--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090
	    
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_4,tipo_asiento,monto_extra_4,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c39',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 4


--INICIO Cuenta extra 5, a�adir kdmm.62, kdmm.c40, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c40/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
		/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
		*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then
		select '<varcont><n5>62</n5><n6>40</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_5 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_5 is not null and cuenta_extra_5 <> '' and monto_extra_5 <> 0 then
		
			--Comentado el 20221207 2355 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
	    	--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_5,tipo_asiento,monto_extra_5,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c40',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
				
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 5

--INICIO Cuenta extra 6, a�adir kdmm.63, kdmm.c41, cuenta costo
	cuenta_contable_kdmm := (xpath('//row/c41/text()', xmlKDMM))[1]::text;
	funCuenta = '';
	expSql = '';
	if trim(cuenta_contable_kdmm) <> '' and position(substring(cuenta_contable_kdmm,1,1) in '1234567890') = 0 then 
/*
		if uen = 'VEN' then
			funCuenta:='cont_v';
		end if;
*/
		if upper(cuenta_contable_kdmm) = 'VENTA_TALLER' or upper(cuenta_contable_kdmm) = 'SUSTITUCION' then
			funCuenta:='cont_venta_taller';
		end if;
	end if;
	if funCuenta = '' then	
		select '<varcont><n5>63</n5><n6>41</n6></varcont>'::xml into varcont;
		select * into resultado, mensaje, adicionales 
			from keplersc.cont_format_account_smov(xmlKDM1, xmlKDMM,folio_operacion,varcont);	
		cuenta_extra_6 := split_part(adicionales, '|', 1);
		descripcion_partida :=  split_part(adicionales, '|', 2); 
		descripcion_cuenta := split_part(adicionales, '|', 3);
	
		if cuenta_extra_6 is not null and cuenta_extra_6 <> '' and monto_extra_6 <> 0 then
		
			--Comentado el 20221207 2355 por JMM, para que tome el tipo de asiento por Naturaleza
			--que seria el valor asignado a la variable B8090
		
	    	--tipo_asiento = 'C'; --K75, cuentas extra son cargo, var B8090

			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta_extra_6,tipo_asiento,monto_extra_6,descripcion_partida,referencia,descripcion_cuenta);
		
		end if;
	else
		strValor:=xmlKDM1::text;
		strValorB :=xmlKDMM::text;	
		expSql:=format('select * from keplersc.%1$s(%3$L,%4$L,%2$L)',funCuenta,'c41',strValor,strValorB);
		execute expSql into xmlCuentas;
		--Validar errores
		strValor := coalesce((xpath('//poliza/poliza_enc/error/text()',xmlCuentas))[1],'');
		if strValor='0' then
			strValor := coalesce((xpath('//poliza/poliza_enc/no_partidas/text()',xmlCuentas))[1],'');
			total_registros = strValor::int;
			for cont in 1..total_registros loop
				cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/cuenta/text()',xmlCuentas))[1]::text;
				descripcion_cuenta:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_cuenta/text()',xmlCuentas))[1]::text;
				tipo_asiento:=(xpath('//poliza/partidas/partida_' || cont::text || '/tipo_asiento/text()',xmlCuentas))[1]::text;
				strValor:=(xpath('//poliza/partidas/partida_' || cont::text || '/monto/text()',xmlCuentas))[1]::text;
				monto_partida:=strValor::decimal;
				descripcion_partida:=(xpath('//poliza/partidas/partida_' || cont::text || '/descripcion_partida/text()',xmlCuentas))[1]::text;
						
			insert into tmpkdc2 (c3,c4,c5,c6,c7,desc_cuenta) values(cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia,descripcion_cuenta);
			end loop;			
		else
			raise exception '%', strValor;
		end if;
	end if;	
--FIN Cuenta extra 6
/*
--Revision de cuentas, para efectos de debug de funcion
	for cuenta,tipo_asiento,monto_cargo,descripcion_cuenta,descripcion_partida, referencia in 
		select c3 as cuenta, c4 as tipo_asiento, c5 as monto_cargo, desc_cuenta as descripcion_cuenta, c6 as descripcion_partida, c7 as referencia 
		from tmpkdc2
	loop 
		raise notice 'Cuenta: %, Asiento: %, monto: %, desc_cta: %, desc_partida: %, referencia: %',cuenta, tipo_asiento,monto_cargo, descripcion_cuenta,descripcion_partida, referencia;		
	end loop;
*/

--raise notice 'PASO 12';
	accion_poliza := 'NUEVAPOLIZA';
--VALIDACION DE CUENTAS creadas para la poliza
	cuentas_validas:=1;
/*
	for cuenta,tipo_asiento,monto_cargo,descripcion_cuenta,referencia in 
		select c3 as cuenta, c4 as tipo_asiento, c5 as monto_cargo, desc_cuenta as descripcion_cuenta, c7 as referencia 
		from tmpkdc2
	loop 
		expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta);	
		execute expSql into intValor;
		if intValor = 0 then --La cuenta no existe
			--Validar si la cuenta es de ultimo nivel
			expSql = format('select count(*) from %1$s where position(%2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)
				and length(c1) > length(%2$L)',
				tabla_cuentas,cuenta);
			execute expSql into intValor;
			if intValor > 0 then --no es cuenta de mas bajo nivel
				cuentas_validas = 0;
				adicionalesStr:=adicionalesStr || 'Imposible agregar, la cuenta no es de �ltimo nivel. ' || cuenta || '|';
				update tmpkdc2 set cuenta_validacion = 'La cuenta no se puede agregar, no es de �ltimo nivel.';
			else
				--Obtencion de la descripcion de la cuenta
				expSql=format('insert into %1$s (c1,c2) values(%2$L,%3$L)',tabla_cuentas,cuenta,substring(descripcion_cuenta,1,40));
				execute expSql;
				adicionalesStr:=adicionalesStr || 'Se agreg� la cuenta: ' || cuenta || ', ' || descripcion_cuenta  || '|';
			end if;	
		end if;		
	end loop;

	if cuentas_validas=0 then
		raise exception '%', adicionalesStr;
	end if;
*/

--INSERCION DE PARTIDAS en tabla de movimientos de poliza
	--Obtener el folio de la poliza
	--Formato fecha operacion YYYY-MM-DD, ejemplo: 2022-01-07

	--VCSS 2025-01-13  Verificacion de artidas de poliza creadas
	select count(*) into total_registros from tmpkdc2;
	if total_registros = 0 then
		raise exception 'No se crearon partidas para la poliza del movimiento, revise e intente nuevamente.';
	end if;

	folio_id := 'POLIZA' || tipo_poliza_kdmm || substring(fecha_operacion, 3, 2) || substring(fecha_operacion, 6, 2);
	select * into resultado, mensaje, adicionales from keplersc.obtener_folio_poliza(folio_id);
	if resultado = '0' then
		raise exception '%',mensaje;
	end if;
	folio_poliza := mensaje::int;
	accion_poliza := 'NUEVAPOLIZA';
	numero_partida_poliza :=0;
	for cuenta,tipo_asiento,monto_partida,descripcion_partida,referencia in 
		select c3 as cuenta, c4 as tipo_asiento, c5 as monto_partida, c6 as descripcion_partida, c7 as referencia 
		from tmpkdc2
	loop 
		numero_partida_poliza = numero_partida_poliza + 1;
		--CONT(T,A9,B8002,B8090,B8052,B8020,A11,M18,"","","","",A1...A6,B8095)
		select xmlforest(fecha_operacion as fecha, cuenta as cuenta, tipo_asiento as tipo_asiento, 
		   monto_partida as monto,descripcion_partida as descrip, referencia as refer, 
		   tipo_poliza_kdmm as tipo_poliza,'' as moneda, '' as depto, '' as concepto, '' as proyecto,
		   sucursal_id as sucursal, genero, naturaleza, grupo, tipo_clave, folio_operacion,
		   accion_poliza as accion_poliza,folio_poliza as folio_poliza,
		   numero_partida_poliza as numero_partida)::text into strValor;				  		  
		select '<varcont>'||strValor||'</varcont>' into strValor;
		partidasStr := '<partida' || numero_partida_poliza || '>' || partidasStr || strValor || '</partida' || numero_partida_poliza || '>';
		varcont := strValor::xml;
		--raise notice 'cuenta:% tipo_asiento:% monto_partida:% descripcion_partida:%',cuenta,tipo_asiento,monto_partida,descripcion_partida;
--raise notice 'PASO 1 cont_general_alta, partida:% Inicio', numero_partida_poliza;		
		select * into resultado, mensaje, adicionales from keplersc.cont_poliza_partida_alta(varcont); 
--raise notice 'PASO 1 cont_general_alta, partida:% Fin', numero_partida_poliza;

		if resultado = '0' then
			raise exception '%',mensaje;
		end if;
				
	end loop;

	--VCSS 2025-01-13 Validar que se haya generado la poliza
	tabla_polizas := 'keplersc.kdc2' || anio_en_curso || mes_en_curso;
	expSql:=format('select count(*) from %1$s where c1=%2$s and c8=%3$L',tabla_polizas,folio_poliza,tipo_poliza_kdmm);
	execute expSql into total_registros;	
	if total_registros = 0 then
		raise exception 'No se registraron las partidas para la poliza del movimiento, revise e intente nuevamente.';
	end if;

	/*
	-- For Testing ... JMM 20240619
	raise exception '%','Completo la Poliza sin Errores ...';
	*/

	resultado := 1;
	mensaje := folio_poliza::text;
	adicionales := adicionalesStr;
	return query select resultado, mensaje, adicionales;	

exception
	when others then
	raise notice '%',sqlerrm;
		resultado := 0;
		mensaje := 'cont_general_alta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
