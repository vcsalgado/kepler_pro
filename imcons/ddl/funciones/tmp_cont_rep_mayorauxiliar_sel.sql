CREATE OR REPLACE FUNCTION keplersc.tmp_cont_rep_mayorauxiliar_sel(fecha_ini date, fecha_fin date, cuenta_ini text, cuenta_fin text, nivel_reporte text, sin_saldo boolean, id_job uuid)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
declare

	intNivel int = 0;
	error text = '';
	str_mes_ini text = '';
	str_mes_fin text = '';
	int_mes_ini int = 0;
	int_mes_fin int = 0;
	str_anio text = '';
	expSql text = '';
	resultadoXml xml;
	cont int = 0;
	totReg int =0 ;
	curTabla text = '';
	tablakdc1 text = '';
	tablakdc2 text ='';
	campo_base_pesos_cargos_kdc1 int = 27;
	campo_base_pesos_abonos_kdc1 int = 63;
	strValor text = '';
	monto_movto numeric(15,2);
	xmlMovtos xml;

	--Variables proceso nivel cuenta
	strCadenaCuentas text = '';
	strTmpCadena text = '';
	tmpCuenta text = '';
	ultima_cuenta text = '';
	cuenta_base text = '';
	nivel_cuenta int = 0;
	cont_cuentas int =0;
	niveles_totales int =0;
	es_subcuenta text = '';
	total_cargos numeric(15,2);
	total_abonos numeric(15,2);
	cont_movtos int = 0;
	cont_orden int = 0;

	--variables de grupo de cuentas
	cta_activo_circulante_ini text = '';
	cta_activo_circulante_fin text = '';
	cta_activo_fijo_ini text = '';
	cta_activo_fijo_fin text = '';
	cta_activo_diferido_ini text = '';
	cta_activo_diferido_fin text = '';
	cta_pasivo_circulante_ini text = '';
	cta_pasivo_circulante_fin text = '';
	cta_pasivo_largo_plazo_ini text = '';
	cta_pasivo_largo_plazo_fin text = '';
	cta_capital_contable_ini text= '';
	cta_capital_contable_fin text= '';
	cta_ventas_ini text = '';
	cta_ventas_fin text = '';
	cta_costo_ventas_ini text = '';
	cta_costo_ventas_fin text = '';
	cta_gastos_ini text = '';
	cta_gastos_fini text = '';
	cta_gastos_prod_financieros_ini text = '';
	cta_gastos_prod_financieros_fin text = '';
	cta_isr_ptu_ini text = '';
	cta_isr_ptu_fin text = '';
	cta_cuentas_orden_ini text = '';
	cta_cuentas_orden_fin text = '';

	saldoCuenta text = '';
	saldoSaldo_inicial numeric(15,2) =0.00;
	saldoDescripcion text = '';
	saldoFecha text = '';

	--Variables tabla temporal kdc1
	fecha text = '';
	cuenta text = '';
	tipo_poliza text = '';
	poliza text = '';
	referencia text = '';
	sucursal text = '';
	movimiento text = '';
	usuario text = '';
	desc_poliza text = '';
	tipo_asiento text = '';
	cargo_poliza numeric(15,2) = 0.00;
	abono_poliza numeric(15,2) = 0.00;

	--variables de retorno
	mayorAuxiliar xml;
begin

	intNivel=nivel_reporte::int;
	str_anio := substring(fecha_ini::text, 3, 2);
	str_mes_ini = substring(fecha_ini::text, 6, 2);
	str_mes_fin = substring(fecha_fin::text, 6, 2);
	int_mes_ini = str_mes_ini::int;
	int_mes_fin = str_mes_fin::int;


	--Iniciar variables de grupo
	select c4 into cta_activo_circulante_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 0;
	select c4 into cta_activo_circulante_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 1;
	select c4 into cta_activo_fijo_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 2;
	select c4 into cta_activo_fijo_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 3;
	select c4 into cta_activo_diferido_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 4;
	select c4 into cta_activo_diferido_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 5;
	select c4 into cta_pasivo_circulante_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 6;
	select c4 into cta_pasivo_circulante_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 7;
	select c4 into cta_pasivo_largo_plazo_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 8;
	select c4 into cta_pasivo_largo_plazo_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 9;
	select c4 into cta_capital_contable_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 10;
	select c4 into cta_capital_contable_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 11;
	select c4 into cta_ventas_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 12;
	select c4 into cta_ventas_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 13;
	select c4 into cta_costo_ventas_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 14;
	select c4 into cta_costo_ventas_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 15;
	select c4 into cta_gastos_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 16;
	select c4 into cta_gastos_fini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 17;
	select c4 into cta_gastos_prod_financieros_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 18;
	select c4 into cta_gastos_prod_financieros_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 19;
	select c4 into cta_isr_ptu_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 20;
	select c4 into cta_isr_ptu_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 21;
	select c4 into cta_cuentas_orden_ini from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 22;
	select c4 into cta_cuentas_orden_fin from keplersc.sqliov where c1 = 'CUENTAS' and c2 = 23;

	--Obtener la tabla kdc1 con las cuentas a consultar dependiendo del anio
	tablakdc1 := concat('kdc1',str_anio);
	select count(*) into totReg from information_schema.tables
	where table_name = tablakdc1;

	if totReg = 0 then
		raise exception 'No se tiene informaci?n contable para el a?o %, tabla(%)', substring(fecha_ini::text, 3, 2),tablakdc1;
	end if;


	--Crear tabla temporal del reporte
	drop table if exists auxiliar;
	create temp table auxiliar(
		cuenta varchar(20),
		descripcion varchar(60),
		grupo int,
		nombre_grupo varchar(40),
		nivel int,
		saldo_inicial numeric(15,2) default 0,
		cargos numeric(15,2),
		abonos numeric(15,2),
		saldo_final numeric(15,2),
		polizas xml,
		orden int default 0
	);

	--Obtener el nivel mas alto de la cuenta inicial
	tmpCuenta := concat(cuenta_ini,'%');
	expSql:=format('select coalesce(min(c1),%3$L) from keplersc.%1$s where position(c1 in %2$L)=1 and c1<>%3$L',tablakdc1,tmpCuenta,'');

	execute expSql into strValor;

	if strValor <> '' then
		cuenta_ini = strValor;
	end if;

	--Obtener el ultimo nivel de la cuenta final
	tmpCuenta := concat(cuenta_fin,'%');
	expSql:=format('select coalesce(max(c1),%3$L) from keplersc.%1$s where c1 like %2$L',tablakdc1,tmpCuenta,'');

	execute expSql into strValor;

	if strValor <> '' then
		cuenta_fin = strValor;
	end if;

	--Llenar la tabla auxiliar calculando los niveles de las cuentas de kdc1, guardar saldo inicial al 1 de enero (c14)
	expSql = format('insert into auxiliar(cuenta,descripcion,saldo_inicial,nivel,cargos,abonos,saldo_final) 
		select c1,c2,c14,0,0,0,0 from keplersc.%1$s where c1 >= %2$L and c1 <= %3$L ',tablakdc1,cuenta_ini,cuenta_fin); 

	execute expSql;

	create index auxiliar_1_idx on auxiliar (cuenta);	

	--Determinar niveles de cuentas
	ultima_cuenta := '';
	cuenta_base := '';
	niveles_totales:=0;
	strCadenaCuentas := '';
	strTmpCadena := '';
	cont_orden := 0;
	for ultima_cuenta in 
		select kdc1.cuenta as ultima_cuenta from auxiliar as kdc1 where kdc1.cuenta <> '' order by kdc1.cuenta
	loop
--raise notice 'ultima_cta: %',ultima_cuenta;		
		nivel_cuenta := 0;
		es_subcuenta := 'N';
		if strCadenaCuentas <> '' then
		
			for cont_cuentas in 1 .. niveles_totales loop
				tmpCuenta := split_part(strCadenaCuentas, '|', cont_cuentas);
			
				if  position(tmpCuenta in ultima_cuenta) = 1 then
					nivel_cuenta := nivel_cuenta + 1;
					es_subcuenta='S';
				else
					es_subcuenta='N';
				end if;

				if strTmpCadena <> '' then
					strTmpCadena := concat(strTmpCadena,'|');
				end if;
			
				if es_subcuenta = 'S' then 
					strTmpCadena := concat(strTmpCadena,tmpCuenta);
				else
					exit;
				end if;
	
			end loop;
		
			--Agregar cuenta al final de la cadena
			if strTmpCadena <> ''  then
				if right(strTmpCadena,1) <> '|' then
					strTmpCadena := concat(strTmpCadena,'|');	
				end if;
				nivel_cuenta := nivel_cuenta +1;
				strTmpCadena := concat(strTmpCadena,ultima_cuenta);				
			else 
				nivel_cuenta := 1;
				strTmpCadena := ultima_cuenta;						
			end if;		
				
		else --Inicial
			nivel_cuenta:=1;
			niveles_totales:=1;
			strTmpCadena:=ultima_cuenta;
		end if;
		strCadenaCuentas:=strTmpCadena;
		niveles_totales := nivel_cuenta;
		strTmpCadena:='';
		cont_orden := cont_orden + 1;
		update auxiliar as aux set nivel = nivel_cuenta, orden= cont_orden where aux.cuenta = ultima_cuenta;
	end loop;	
--raise notice 'Paso 1';

--raise notice 'Actualizando saldos';
	for tmpCuenta in 
		select aux.cuenta as tmpCuenta from auxiliar aux where aux.cuenta <> ''
	loop
		select _cuenta,_descripcion,_fecha,_saldo_inicial 
			into saldoCuenta, saldoDescripcion, saldoFecha, saldoSaldo_inicial
			from keplersc.cont_cuentaobtenersaldoini(tmpCuenta,fecha_ini::text);
		update auxiliar aux set saldo_inicial=	saldoSaldo_inicial where aux.cuenta=tmpCuenta;
	end loop;
--raise notice 'FIN de Actualizando saldos';

	--Registrar el grupo al que pertenece la cuenta, esto se aplica con base en el primer
	--nivel de la cuenta, campos grupo y nombre_grupo
	update auxiliar as aux set 
		grupo=(case when aux.cuenta>=cta_activo_circulante_ini and aux.cuenta<=cta_activo_circulante_fin then 0      
		when aux.cuenta>=cta_activo_fijo_ini and aux.cuenta<=cta_activo_fijo_fin then 1
        	when aux.cuenta>=cta_activo_diferido_ini and aux.cuenta<=cta_activo_diferido_fin then 2
        	when aux.cuenta>=cta_pasivo_circulante_ini and aux.cuenta<=cta_pasivo_circulante_fin then 3
        	when aux.cuenta>=cta_pasivo_largo_plazo_ini and aux.cuenta<=cta_pasivo_largo_plazo_fin then 4
        	when aux.cuenta>=cta_capital_contable_ini and aux.cuenta<=cta_capital_contable_fin then 5
        	when aux.cuenta>=cta_ventas_ini and aux.cuenta<=cta_ventas_fin then 6
        	when aux.cuenta>=cta_costo_ventas_ini and aux.cuenta<=cta_costo_ventas_fin then 7
        	when aux.cuenta>=cta_gastos_ini and aux.cuenta<=cta_gastos_fini then 8
        	when aux.cuenta>=cta_gastos_prod_financieros_ini and aux.cuenta<=cta_gastos_prod_financieros_fin then 9
        	when aux.cuenta>=cta_isr_ptu_ini and aux.cuenta<=cta_isr_ptu_fin then 10
        	when aux.cuenta>=cta_cuentas_orden_ini and aux.cuenta<=cta_cuentas_orden_fin then 11
        	else 99
         	end),
         nombre_grupo=(case when aux.cuenta>=cta_activo_circulante_ini and aux.cuenta<=cta_activo_circulante_fin then 'ACTIVO CIRCULANTE'     
        	when aux.cuenta>=cta_activo_fijo_ini and aux.cuenta<=cta_activo_fijo_fin then 'ACTIVO FIJO'
        	when aux.cuenta>=cta_activo_diferido_ini and aux.cuenta<=cta_activo_diferido_fin then 'ACTIVO DIFERIDO'
        	when aux.cuenta>=cta_pasivo_circulante_ini and aux.cuenta<=cta_pasivo_circulante_fin then 'PASIVO CIRCULANTE'
        	when aux.cuenta>=cta_pasivo_largo_plazo_ini and aux.cuenta<=cta_pasivo_largo_plazo_fin then 'PASIVO A LARGO PLAZO'
        	when aux.cuenta>=cta_capital_contable_ini and aux.cuenta<=cta_capital_contable_fin then 'CAPITAL CONTABLE'
        	when aux.cuenta>=cta_ventas_ini and aux.cuenta<=cta_ventas_fin then 'VENTAS' 
        	when aux.cuenta>=cta_costo_ventas_ini and aux.cuenta<=cta_costo_ventas_fin then 'COSTO DE VENTAS'
        	when aux.cuenta>=cta_gastos_ini and aux.cuenta<=cta_gastos_fini then 'gastos'
        	when aux.cuenta>=cta_gastos_prod_financieros_ini and aux.cuenta<=cta_gastos_prod_financieros_fin then 'GASTOS PRODUCTOS FINANCIEROS'
        	when aux.cuenta>=cta_isr_ptu_ini and aux.cuenta<=cta_isr_ptu_fin then 'ISR Y PTU'
        	when aux.cuenta>=cta_cuentas_orden_ini and aux.cuenta<=cta_cuentas_orden_fin then 'CUENTAS DE ORDEN'
        	else 'CUENTAS SIN GRUPO'
         	end);
--raise notice 'Paso 2';

	-- crear tabla tempora a partir de kdc2, sin registros
	drop table if exists tmpkdc2;
	create temp table tmpkdc2 as (
		select k.*, w.c67 as usuario from keplersc.kdc22309 as k
	       	inner join keplersc.kdm1 w on w.c1 = k.c14
	       	and w.c2 = k.c15
	       	and w.c3 = k.c16
	       	and w.c4 = k.c17
	       	and w.c5 = k.c18
	       	and w.c6 = k.c19
	);
	create index tmpKdc2_1_idx on tmpkdc2 (c1,c2);
	create index tmpKdc2_2_idx on tmpkdc2 (c5,c16,c17,c18,c19);
	create index tmpKdc2_3_idx on tmpkdc2 (c3,c2,c1);

	--Calcular saldos iniciales de las cuentas, obtener registros de tablas kdc2 para movimientos previos
	--a la fecha de inicio del reporte, obtener registros
	for cont in 1 .. int_mes_ini loop
		curTabla := concat('kdc2',str_anio,lpad(cont::text,2,'0'));	
		select count(*) into totReg from information_schema.tables
		where table_name  = curTabla;
		if totReg>0 then
			expSql:=format('insert into tmpkdc2 select k.*, w.c67 as usuario from keplersc.%1$s as k
				inner join keplersc.kdm1 w on w.c1 = k.c14
				and w.c2 = k.c15
				and w.c3 = k.c16
				and w.c4 = k.c17
				and w.c5 = k.c18
				and w.c6 = k.c19
				where k.c3 >= %2$L and k.c3 <= %3$L and k.c2<%4$L'
				,curTabla,cuenta_ini,cuenta_fin,fecha_ini);
			execute expSql;
		end if;		
	end loop;

--raise notice 'Paso 3';
/*
	--Calcular saldos iniciales,procesar registros de cargos y abonos para actualizar saldos iniciales
	for tipo_asiento, cargo_poliza, abono_poliza, tmpCuenta in 
		select kdc2.c4 as tipo_asiento, 
		case
			when (kdc2.c4 = 'C') then kdc2.c5
		  else 0
		end as cargo_poliza,
		case
			when (kdc2.c4 = 'A') then kdc2.c5
		  else 0
		end as abono_poliza,
		kdc2.c3 as tmpCuenta
		from tmpkdc2 kdc2  
		order by c3
	loop
		--Actualizar saldos de cuenta y padres		
		expSql=format('update auxiliar set saldo_inicial = saldo_inicial + %1$s -  %2$s where position(cuenta in %3$L) = 1 '
			,cargo_poliza, abono_poliza, tmpCuenta);
		execute expSql;
	end loop;
*/


--raise notice 'Paso 4';
	--Obtener los cargos y abonos del periodo 
	--Copiar los registros de las kdc2 a la tabla temporal dependiendo de los criterios
	truncate tmpkdc2;
	for cont in int_mes_ini .. int_mes_fin loop
		curTabla := concat('kdc2',str_anio,lpad(cont::text,2,'0'));			
		select count(*) into totReg from information_schema.tables
		where table_name  = curTabla;
		if totReg>0 then
			expSql:=format('insert into tmpkdc2 select k.*, w.c67 as usuario from keplersc.%1$s as k
				inner join keplersc.kdm1 w on w.c1 = k.c14
				and w.c2 = k.c15
				and w.c3 = k.c16
				and w.c4 = k.c17
				and w.c5 = k.c18
				and w.c6 = k.c19
				where k.c3 >= %2$L and k.c3 <= %3$L and k.c2>=%4$L and k.c2<=%5$L'
				,curTabla,cuenta_ini,cuenta_fin,fecha_ini,fecha_fin);			
			execute expSql;
		
		end if;
	end loop;
--raise notice 'Paso 5';
	--Procesar registros de cargos y abonos
	ultima_cuenta = '';
	total_cargos := 0;
	total_abonos := 0;
	cont_movtos := 0;
	xmlMovtos := '';
	for fecha, tipo_poliza, poliza, referencia, sucursal, movimiento, usuario, desc_poliza, tipo_asiento, cargo_poliza, abono_poliza, tmpCuenta in 
		select kdc2.c2 as fecha, kdc2.c8 as tipo_poliza, kdc2.c1 as poliza,
		kdc2.c7 as referencia, 
		kdc2.c14 as sucursal, 
		concat(kdc2.c15,kdc2.c16,lpad(kdc2.c17::text,2,'0'),lpad(kdc2.c18::text,2,'0'),'-',lpad(kdc2.c19::text,7,'0')) as movimiento,
		kdc2.usuario, 
		kdc2.c6 as desc_poliza, 
		kdc2.c4 as tipo_asiento, 
		case
			when (kdc2.c4 = 'C') then kdc2.c5
		  else 0
		end as cargo_poliza,
		case
			when (kdc2.c4 = 'A') then kdc2.c5
		  else 0
		end as abono_poliza,
		kdc2.c3 as tmpCuenta
		from tmpkdc2 kdc2  
		order by c3
	loop
--raise notice 'Movtos: %',cont_movtos;	
		if cargo_poliza=0 and abono_poliza=0 then
			continue;
		end if;
		if tmpCuenta <> ultima_cuenta then
			if ultima_cuenta <> tmpCuenta then
				--Actualizar cargos, abonos y movimientos y saldos de cuenta y padres		
				expSql=format('update auxiliar as aux set cargos = cargos + %1$s, abonos = abonos + %2$s where position(aux.cuenta in %3$L) = 1 '
					,total_cargos, total_abonos, ultima_cuenta);
				execute expSql;
				--Actualizar xml de movimientos de la cuenta
				xmlMovtos := concat('<document>', xmlMovtos ,'</document>');
				update auxiliar as aux set polizas = xmlMovtos::xml where aux.cuenta = ultima_cuenta;
			end if;
			--Reiniciar contadores
			ultima_cuenta := tmpCuenta;
			total_cargos := 0;
			total_abonos := 0;
			cont_movtos := 0;
			xmlMovtos := '';
		end if; 
		cont_movtos:=cont_movtos + 1;
		total_cargos := total_cargos + cargo_poliza;
		total_abonos := total_abonos + abono_poliza;
		desc_poliza:=replace(desc_poliza,'<','');
		desc_poliza:=replace(desc_poliza,'>','');
		desc_poliza:=replace(desc_poliza,'/','');
		desc_poliza:=replace(desc_poliza,E'\'','');
		desc_poliza:=replace(desc_poliza,'&','');
		strTmpCadena := format('<r%1$s>
			<fecha>%2$s</fecha>
			<tipo_poliza>%3$s</tipo_poliza>
			<poliza>%4$s</poliza>
			<referencia>%5$s</referencia>
			<sucursal>%6$s</sucursal>
			<movimiento>%7$s</movimiento>
			<usuario>%8$s</usuario>
			<desc_poliza>%9$s</desc_poliza>
			<tipo_asiento>%10$s</tipo_asiento>
			<cargo_poliza>%11$s</cargo_poliza>
			<abono_poliza>%12$s</abono_poliza>
			</r%1$s>',cont_movtos::text,fecha::text,tipo_poliza,poliza::text,referencia,sucursal,movimiento,usuario,desc_poliza,tipo_asiento,cargo_poliza,abono_poliza); 
		xmlMovtos := concat(xmlMovtos,strTmpCadena);
	end loop;

--raise notice 'Paso 6';

	--Agregar ultimo registro
	expSql=format('update auxiliar as aux set cargos = cargos + %1$s, abonos = abonos + %2$s where position(aux.cuenta in %3$L) = 1 '
		,total_cargos, total_abonos, ultima_cuenta);
	execute expSql;
	--Actualizar xml de movimientos de la cuenta
	xmlMovtos := concat('<document>', xmlMovtos ,'</document>');
	update auxiliar as aux set polizas = xmlMovtos::xml where aux.cuenta = ultima_cuenta;

	--Actualizar Saldos Finales
	update auxiliar set saldo_final = saldo_inicial+cargos-abonos;	

	--Elimiminar niveles no solicitados
	delete from auxiliar where nivel > intNivel;

	--Eliminar sin saldo
	if sin_saldo is false then
		delete from auxiliar where saldo_inicial= 0 and cargos=0 and abonos=0 and saldo_final=0;
	end if;
	
	delete from keplersc.tmp_cont_rep_mayor_auxiliar where fecha_ejecucion < current_date;
	INSERT INTO keplersc.tmp_cont_rep_mayor_auxiliar
	(cuenta, descripcion, grupo,nombre_grupo,nivel,saldo_inicial,cargos,abonos,saldo_final,polizas, id_job, fecha_ejecucion, orden)
	select 
		aux.cuenta, 
		aux.descripcion, 
		aux.grupo, 
		aux.nombre_grupo, 
		aux.nivel,
		aux.saldo_inicial,
		aux.cargos,
		aux.abonos,
		aux.saldo_final,
		aux.polizas,
		id_job,
		current_date,
		aux.orden
	from auxiliar as aux;

	return 1;
	
exception
	when others then
		error := 'keplersc.tmp_cont_rep_mayorauxiliar_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
end;
$function$
