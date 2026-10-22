CREATE OR REPLACE FUNCTION keplersc.tmp_cont_rep_auxiliar_sel(cuenta_inicial text, cuenta_final text, fecha_inicial timestamp without time zone, fecha_final timestamp without time zone, id_job uuid)
 RETURNS numeric
 LANGUAGE plpgsql
AS $function$
declare 
	--Creado por Victor Salgado 28 dic 2022
	--Variables de definicion de documento
	fecha_ini text = ''; 
	fecha_fin text = '';
	cuenta_ini text = '';
	cuenta_fin text = '';

	--Variables de proceso
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
	strValor text = '';

	saldoCuenta text = '';
	saldoSaldo_inicial numeric(15,2) =0.00;
	saldoDescripcion text = '';
	saldoFecha text = '';

	--Variables proceso nivel cuenta
	tmpCuenta text = '';
	ultima_cuenta text = '';
	cont_orden int =0;
	total_cargos numeric(15,2);
	total_abonos numeric(15,2);
	cont_movtos int = 0;
	cuenta_saldo_final numeric(15,2);
	cuenta_saldo_inicial numeric(15,2);
	no_partida numeric(4) = 0;

	--Variables tabla temporal kdc1
	fecha timestamp;
	cuenta text = '';
	tipo_poliza text = '';
	poliza int = 0;
	referencia text = '';
	movimiento text = '';
	desc_poliza text = '';
	tipo_asiento text = '';
	cargo_poliza numeric(15,2) = 0.00;
	abono_poliza numeric(15,2) = 0.00;

	
	desc_movto_mm text = '';
	usuario_movto text = '';
	--variables de retorno
	xmlAuxiliar xml;
begin	
	fecha_ini := (xpath('//document/fecha_ini/text()', dataxml))[1]; --aaaa-mm-dd
	fecha_fin := (xpath('//document/fecha_fin/text()', dataxml))[1]; --aaaa-mm-dd
	cuenta_ini := coalesce((xpath('//document/cta_ini/text()', dataxml))[1],'0');
	cuenta_fin := coalesce((xpath('//document/cta_fin/text()', dataxml))[1],'Z');

	str_anio := substring(fecha_ini, 3, 2);
	str_mes_ini = substring(fecha_ini, 6, 2);
	str_mes_fin = substring(fecha_fin, 6, 2);
	int_mes_ini = str_mes_ini::int;
	int_mes_fin = str_mes_fin::int;

	--Obtener la tabla kdc1 con las cuentas a consultar dependiendo del anio
	tablakdc1 := concat('kdc1',str_anio);
	select count(*) into totReg from information_schema.tables 
	where table_name = tablakdc1;

	if totReg = 0 then
		raise exception 'No se tiene información contable para el año %, tabla(%)', substring(fecha_ini, 3, 2),tablakdc1;
	end if;

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

	-- crear tabla temporal a partir de kdc2, sin registros
	delete from keplersc.tmp_cont_rep_auxiliar 
	where to_date(fecha, 'yyyy-mm-dd') < current_date;
	create temp table tmpkdc2 as select * from keplersc.kdc2;

	create index tmpKdc2_1_idx on tmpkdc2 (c1,c2);
	create index tmpKdc2_2_idx on tmpkdc2 (c5,c16,c17,c18,c19);
	create index tmpKdc2_3_idx on tmpkdc2 (c3,c2,c1);


	--Obtener los cargos y abonos del periodo 
	--Copiar los registros de las kdc2 a la tabla temporal dependiendo de los criterios
	truncate tmpkdc2;
	for cont in int_mes_ini .. int_mes_fin loop
		curTabla := concat('kdc2',str_anio,lpad(cont::text,2,'0'));		
		select count(*) into totReg from information_schema.tables
		where table_name  = curTabla;
		if totReg>0 then
			expSql:=format('insert into tmpkdc2 select * from keplersc.%1$s 
				where c3 >= %2$L and c3 <= %3$L and c2>=%4$L and c2<=%5$L 
				order by c3,c2,c8,c1,c10'
				,curTabla,cuenta_ini,cuenta_fin,fecha_ini,fecha_fin);			
			execute expSql;
	
		end if;
	end loop;
	alter table tmpkdc2 add column desc_movto varchar(40) default '';
	alter table tmpkdc2 add column desc_cuenta varchar(40) default '';
	alter table tmpkdc2 add column usuario varchar(20) default '';	
	alter table tmpkdc2 add column saldo_inicial numeric(15,2) default 0.00;
	alter table tmpkdc2 add column cargos numeric(15,2) default 0.00;
	alter table tmpkdc2 add column abonos numeric(15,2) default 0.00;
	alter table tmpkdc2 add column saldo_final numeric(15,2) default 0.00;
	alter table tmpkdc2 add column orden int default 0;
	alter table tmpkdc2 add constraint tmpkdc2_pk primary key (c3,c2,c8,c1,c10); 

	--Procesar registros de cargos y abonos
	ultima_cuenta = '';
	total_cargos := 0;
	total_abonos := 0;
	cont_movtos := 0;
	cont_orden :=0;
	for fecha, tipo_poliza, poliza, referencia, movimiento, desc_poliza, 
		tipo_asiento, cargo_poliza, abono_poliza, tmpCuenta, desc_movto_mm,usuario_movto, 
		no_partida in 
		select kdc2.c2 as fecha, kdc2.c8 as tipo_poliza, kdc2.c1 as poliza,
		kdc2.c7 as referencia, 
		concat(kdc2.c15,kdc2.c16,lpad(kdc2.c17::text,2,'0'),lpad(kdc2.c18::text,2,'0'),'-',lpad(kdc2.c19::text,7,'0')) as movimiento,
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
		kdc2.c3 as tmpCuenta, 
		mm.c5 as desc_movto_mm,
		m1.c67 as usuario_movto, 
		kdc2.c10
		from tmpkdc2 kdc2 left outer join keplersc.kdmm mm on
		mm.c1=kdc2.c15 and mm.c2=kdc2.c16 and mm.c3=kdc2.c17 and mm.c4=kdc2.c18
		left outer join keplersc.kdm1 m1 on 
		m1.c1=kdc2.c14 and m1.c2=kdc2.c15 and m1.c3=kdc2.c16 and m1.c4=kdc2.c17 
		and m1.c5=kdc2.c18 and m1.c6=kdc2.c19
		order by kdc2.c3,kdc2.c2,kdc2.c8,kdc2.c1
	loop
		if tmpCuenta <> ultima_cuenta then
			--obtener saldo inicial
		
			select _cuenta,_descripcion,_fecha,_saldo_inicial 
				into saldoCuenta, saldoDescripcion, saldoFecha, saldoSaldo_inicial
				from keplersc.cont_cuentaobtenersaldoini(tmpCuenta,fecha_ini);
--raise notice 'cuenta:%, fecha:%, Saldo incial:%',tmpCuenta,fecha_ini,cuenta_saldo_inicial;
			cuenta_saldo_inicial:=saldoSaldo_inicial;
			cuenta_saldo_final:=saldoSaldo_inicial;

			--Nueva cuenta
			--Insertar registgro con saldo inicial
			insert into tmpkdc2 (c3,c2,c8,c1,c10,c6,c14,c15,c16,c17,c18,c19,saldo_inicial,
			cargos,abonos,saldo_final,desc_cuenta,desc_movto,usuario,orden) 
			values(tmpCuenta,fecha,'A',0,0,'SALDO INICIAL','00','-','-',0,0,'-',cuenta_saldo_inicial,
			0,0,cuenta_saldo_final,saldoDescripcion,'INICIAL','INICIAL',cont_orden);
			ultima_cuenta:=tmpCuenta;
			cont_orden:=cont_orden+1;
		end if;
		cuenta_saldo_final:=cuenta_saldo_inicial + cargo_poliza - abono_poliza;
raise notice 'Cuenta:% Poliza:% SI:% C:% A:% SF:%',
	tmpCuenta,poliza,cuenta_saldo_inicial,cargo_poliza,abono_poliza,cuenta_saldo_final;
--raise notice 'Usuario %',usuario_movto;	
		cont_movtos:=cont_movtos + 1;
		desc_poliza:=replace(desc_poliza,'<','');
		desc_poliza:=replace(desc_poliza,'>','');
		desc_poliza:=replace(desc_poliza,'/','');
		desc_poliza:=replace(desc_poliza,E'\'','');
		desc_poliza:=replace(desc_poliza,'&','');
		desc_poliza:=replace(desc_poliza,'"','');
		update tmpkdc2 set cargos=cargo_poliza, abonos=abono_poliza, c6=desc_poliza,
			saldo_inicial=cuenta_saldo_inicial, saldo_final=cuenta_saldo_final,
			desc_cuenta=saldoDescripcion, desc_movto=desc_movto_mm, usuario=usuario_movto,
			orden=cont_orden
		where c1=poliza and c2=fecha and c3=tmpCuenta and c8=tipo_poliza and c10=no_partida;
		cuenta_saldo_inicial:=cuenta_saldo_final;
		cuenta_saldo_final:=0;
		cont_orden:=cont_orden+1;
	end loop;

	INSERT INTO keplersc.tmp_cont_rep_auxiliar
	(cuenta, desc_cuenta, tipo_poliza, poliza, referencia, fecha, sucursal, documento, desc_documento, usuario, desc_poliza, cargo, abono, saldo, saldo_inicial, id_consulta, fecha_ejecucion, orden)
	select 
		c3, 
		desc_cuenta, 
		c8, 
		c1, 
		c7,
		c2,
		c14,
		c15||c16||to_char(c17, 'fm00')||to_char(c18, 'fm000')||c19, c10,
		desc_mvto,
		usuario,
		c6,
		cargos,
		abonos,
		saldo_final,
		saldo_inicial,
		id_job,
		current_date,
		orden
	from tmpkdc2;

	return 1;
end;
$function$
