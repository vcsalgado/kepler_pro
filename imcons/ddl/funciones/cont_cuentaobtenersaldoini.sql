CREATE OR REPLACE FUNCTION keplersc.cont_cuentaobtenersaldoini(cuenta_base text, fecha_base text)
 RETURNS TABLE(_cuenta text, _descripcion text, _fecha text, _saldo_inicial numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Creado por Victor Salgado 28 dic 2022
	--Variables de proceso
	_cuenta text = '';
	_saldo_inicial numeric(15,2) =0.00;
	_descripcion text = '';
	_fecha text = '';
	strAnio text = '';
	strMes text = '';
	strDia text = '';
	intAnio int = 0;
	intMes int =0;
	intDia int = 0;
	error text = '';
	kdc1 text ='';
	kdc2 text ='';
	sqlExp text = '';
	cargosMes numeric(15,2)=0.00;
	abonosMes numeric(15,2)=0.00;
	totalMes numeric(15,2)=0.00;
	fecha_ini text;
	fecha_fin text;
	dateFecha date;

	recKdc1 record;
begin
	--'2020-12-10'
	strAnio:=substring(fecha_base,3,2);
	strMes:=substring(fecha_base,6,2);
	strDia:=substring(fecha_base,9,2);
	intAnio:=strAnio::int;
	intMes:=strMes::int;
	intDia:=strDia::int;
	kdc1:= concat('kdc1',lpad(strAnio,2,'0'));
	kdc2:= concat('kdc2',lpad(strAnio,2,'0'),lpad(strMes,2,'0'));
--raise notice 'Dia:%',intDia;
	--Obtener saldo inicial de la cuenta
	sqlExp:=format('select * from keplersc.%1$s where c1=%2$L',kdc1,cuenta_base);
--raise notice 'Query %',sqlExp;
	execute sqlExp into recKdc1;
	_cuenta:=cuenta_base;
	_fecha:=fecha_base;
	_saldo_inicial:=recKdc1.c14;
	_descripcion:=recKdc1.c2;

	--Obtener Saldo inicial al mes
	if intMes > 1 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c27 - recKdc1.c63;
	end if;
	if intMes > 2 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c28 - recKdc1.c64;
	end if;
	if intMes > 3 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c29 - recKdc1.c65;
	end if;
	if intMes > 4 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c30 - recKdc1.c66;
	end if;
	if intMes > 5 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c31 - recKdc1.c67;
	end if;
	if intMes > 6 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c32 - recKdc1.c68;
	end if;
	if intMes > 7 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c33 - recKdc1.c69;
	end if;
	if intMes > 8 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c34 - recKdc1.c70;
	end if;
	if intMes > 9 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c35 - recKdc1.c71;
	end if;
	if intMes > 10 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c36 - recKdc1.c72;
	end if;
	if intMes > 11 then
		_saldo_inicial:=_saldo_inicial + recKdc1.c37 - recKdc1.c73;
	end if;
--raise notice 'Saldo inicial:%',_saldo_inicial;

	--Obtener saldo inicial al dia
	if intDia > 1 then
		strDia:= (intDia-1)::text;
		strDia:= lpad(strDia,2,'0');
		fecha_ini:=substring(fecha_base,1,4) || '-' || strMes ||'-01';
		fecha_fin:=substring(fecha_base,1,4) || '-' || strMes || '-' || strDia;
		sqlExp:=format(' 
			select coalesce(sum(cargos-abonos),0) as total from
			(select 
			case when (c4 = %1$L) then c5
				else 0
			end as cargos,
			case when (c4 = %2$L) then c5
				 else 0
			end as abonos
			from keplersc.%3$s where c3=%4$L and 
			c2>=to_date(%5$L,%7$L) and c2<=to_date(%6$L,%7$L)) as ca
			','C','A',kdc2,cuenta_base,fecha_ini,fecha_fin,'yyyy-mm-dd');
raise notice 'MES: %',sqlExp;
		execute sqlExp into totalMes;
		_saldo_inicial:=_saldo_inicial + totalMes;
	end if;
--raise notice '%,%,%,SI%',_cuenta,_descripcion,_fecha,_saldo_inicial;
	return query select _cuenta, _descripcion, _fecha, _saldo_inicial;
end;
$function$
