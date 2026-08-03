CREATE OR REPLACE FUNCTION keplersc.cont_upd_saldos()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
	--Procedimiento que actualiza los saldos de las cuentas en la tabla kdc1 correspondiente
	--dependiendo el año en la fecha. 
	--Esta funcion se ejecuta desde un trigger en las tablas kdc2...
	--Se asume que la cuenta existe y que es de ultimo nivel, por lo que se valida que así sea, en caso
	--de que esto no se de, se manda un error.
	--Autor: Victor Salgado
	--Fecha: 14 Feb 2023

	cuenta text = '';
	monto numeric = 0.00;
	tipo_asiento text = '';
	fecha timestamp;

--variables de uso general
	anio_en_curso text;
	mes_en_curso text;
	tabla_cuentas text = '';
	campo_cuentas text = '';
	strValor text = '';
	intValor int = 0;
	mensajeError text;
	varcont xml;
	expSql text='';
	campo_base_pesos_cargos_kdc1 int = 27;
	campo_base_pesos_abonos_kdc1 int = 63;

begin
	--Asignar valores a variables, el registro actual es la kdc2 que manda a llamar esta
	--funcion a través del trigger

	if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
		fecha:=new.c2;
	else 
		fecha:=old.c2;
	end if;	

	--Obtener nombre de tabla kdc1 correpondiente
	intValor:=extract(year from fecha);
	strValor:=intValor::text;
	anio_en_curso:= substring(strValor,3,2);

	intValor:=extract(month from fecha);
	strValor:=intValor::text;
	mes_en_curso:= strValor;
	tabla_cuentas:= 'keplersc.kdc1' || anio_en_curso;
	
	--cuentas
	tabla_cuentas := 'keplersc.kdc1' || anio_en_curso;
	intValor := mes_en_curso::int;

	--Validar que la cuenta existe
	if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
		expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,new.c3);	
		execute expSql into intValor;
		if intValor = 0 then --La cuenta no existe
			raise exception 'La cuenta no existe';
		end if;

		--Validar que la cuenta sea de ultimo nivel
		expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)
		and c1<>%2$L',tabla_cuentas,new.c3);
		execute expSql into intValor;	
		if intValor > 0 then --
			raise exception '%', concat('Imposible actualizar saldo, la cuenta ', new.c3, ', no es de último nivel.');
		end if ;	
	
	end if;

	if TG_OP = 'UPDATE' or TG_OP = 'DELETE' then
		expSql := format('select count(*) from %1$s where c1=%2$L',tabla_cuentas,old.c3);	
		execute expSql into intValor;
		if intValor = 0 then --La cuenta no existe
			raise exception 'La cuenta no existe';
		end if;
	
		--Validar que la cuenta sea de ultimo nivel
		expSql = format('select count(*) from %1$s where position( %2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)
		and c1<>%2$L',tabla_cuentas,old.c3);
		execute expSql into intValor;	
		if intValor > 0 then --
			raise exception '%', concat('Imposible actualizar saldo, la cuenta ', old.c3, ', no es de último nivel.');
		end if;
	end if;


	if TG_OP = 'INSERT' then
		tipo_asiento:=new.c4;
		intValor := mes_en_curso::int;
		if tipo_asiento = 'C' then --Cargo
			intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
		else
			intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
		end if;	
		campo_cuentas:=intValor::text;
		--Acumula saldos de cuenta y padres
		expSql=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
			returning 1::text ',tabla_cuentas, campo_cuentas, new.c5, new.c3);
--raise notice 'expSql:% ', expSql;
		execute expSql into strValor;
	end if;

	if TG_OP = 'UPDATE' then
		if 	new.c5<>old.c5 or new.c4<>old.c4 then --Solo si hubo cambios en monto o tipo asiento
			tipo_asiento:=old.c4;
			intValor := mes_en_curso::int;
			if tipo_asiento = 'C' then --Cargo
				intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
			else
				intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
			end if;	
--raise notice 'PASO 1:% ',intValor;
			campo_cuentas:=intValor::text;		
			--Actualizar restando monto anterior
			expSql=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
				returning 1::text ',tabla_cuentas, campo_cuentas, old.c5*-1, old.c3);
raise notice 'expSql:% ', expSql;
			execute expSql into strValor;		

			tipo_asiento:=new.c4;
			intValor := mes_en_curso::int;
			if tipo_asiento = 'C' then --Cargo
				intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
			else
				intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
			end if;	
			campo_cuentas:=intValor::text;
			--Acumula saldos de cuenta y padres
			expSql=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
				returning 1::text ',tabla_cuentas, campo_cuentas, new.c5, new.c3);
raise notice 'expSql:% ', expSql;
			execute expSql into strValor;		
		end if;
--raise exception 'Actualizando';	
	end if;

	if TG_OP = 'DELETE' then
		tipo_asiento:=old.c4;
		intValor := mes_en_curso::int;
		if tipo_asiento = 'C' then --Cargo
			intValor := campo_base_pesos_cargos_kdc1 + intValor - 1;
		else
			intValor := campo_base_pesos_abonos_kdc1 + intValor - 1;
		end if;	
		campo_cuentas:=intValor::text;
		expSql=format('update %1$s set c%2$s = c%2$s + %3$s where position(c1 in %4$L) = 1
			returning 1::text ',tabla_cuentas, campo_cuentas, old.c5*-1, old.c3);
--raise notice 'expSql:% ', expSql;
		execute expSql into strValor;		
	end if;

--raise notice 'Saldos: %', expSql;
	if strValor is null then
	raise notice 'TABLA: % CAMPO_CUENTA: % MONTO:% CUENTA:%', tabla_cuentas, campo_cuentas, monto, cuenta;
		raise exception 'No se acumularon saldos en las cuentas %.',cuenta ;
	end if;
	
--raise notice 'Cuenta actualizada';	
	return new;
end;
$function$
