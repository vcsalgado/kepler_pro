CREATE OR REPLACE FUNCTION keplersc.cont_upd_nivel()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
--Descripcion: Actualiza los niveles de las cuentas en la tabla kdc1 correspondiente y 
--se ejecuta desde un trigger en las tablas kdc1...
--Autor: Miriam Santana
--Fecha: 04/03/2024
--Bitacora de cambios
--2/10/25 Victor Salgado: Se agrega el anio en la validacion de la cuenta en polizas
	
	--Variables de proceso
	cuenta_ini text = '';
	cuenta_fin text = '';
    fecha timestamp;
	anio_cuenta text;
	tabla_cuentas text = '';
	expSql text = '';
	cont int = 0;
	tablakdc1 text = '';
	strValor text = '';
    intValor int = 0;

	--Variables proceso nivel cuenta
	strCadenaCuentas text = '';
	strTmpCadena text = '';
	tmpCuenta text = '';
	ultima_cuenta text = '';
	nivel_cuenta int = 0;
	cont_cuentas int =0;
	niveles_totales int =0;
	es_subcuenta text = '';


    cuenta_actual RECORD;
    cuenta_padre RECORD;
    nivel_actual INT;
    cuenta_padre_actual VARCHAR;
begin	
    --Obtener nombre de tabla kdc1 correpondiente
	anio_cuenta:= right(TG_TABLE_NAME,2);
	tablakdc1:= TG_TABLE_NAME;
    if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then
    	if length(trim(new.c1)) = 0 then 
			raise exception 'Verifique el numero de cuenta, no puede ser vacio %; %',new.c1,new.c2;
		end if;
		cuenta_ini :=new.c1;
        cuenta_fin :=new.c1;
	else 
		cuenta_ini :=old.c1;
        cuenta_fin :=old.c1;
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

	--Determinar niveles de cuentas
 	niveles_totales:=0;
	strCadenaCuentas := '';
	strTmpCadena := '';  
	if TG_OP = 'INSERT' or TG_OP = 'DELETE' or (TG_OP = 'UPDATE' and new.c1<>old.c1) then
		if TG_OP = 'INSERT' then
			select count(*) into intValor
		   		from keplersc.cuentas_niveles
				where cuenta=new.c1 and anio=anio_cuenta;
			if intValor = 0 then
		  		insert  into keplersc.cuentas_niveles (anio, cuenta, cuenta_padre, nivel)
			    	values (anio_cuenta, new.c1, '', 0);
			end if;		
		end if;
		if TG_OP = 'UPDATE' and new.c1<>old.c1 then
			select count(*) into intValor
		   		from keplersc.cuentas_niveles
				where cuenta=old.c1 and anio=anio_cuenta;
			if intValor = 0 then
				update keplersc.cuentas_niveles
		  			set cuenta = new.c1
		  			where cuenta=old.c1 and anio=anio_cuenta;
			end if;		
		end if;
	
		if TG_OP = 'DELETE' then
			delete from keplersc.cuentas_niveles
				where cuenta=old.c1 and anio=anio_cuenta;
		end if;
		expSql:= format('select %1$s ,kdc1.c1 as cuenta from keplersc.%2$s kdc1 where c1 >= %3$L and c1 <= %4$L and kdc1.c1 <> %5$L order by length(kdc1.c1), c1',anio_cuenta,tablakdc1,cuenta_ini,cuenta_fin,'');

	for cuenta_actual in
			execute expSql
		loop	
	        nivel_actual := 1;
	        cuenta_padre_actual := 'mayor';
			--raise notice 'For 1 cuenta_actual:% nivel_actual:% cuenta_padre_actual:%',cuenta_actual.cuenta,nivel_actual,cuenta_padre_actual;
	        for cuenta_padre in 
	        	select cta_n.cuenta, cta_n.nivel 
	        	from keplersc.cuentas_niveles cta_n
	        	where cta_n.anio = anio_cuenta and cta_n.cuenta >= cuenta_ini and cta_n.cuenta <= cuenta_fin and cta_n.nivel > 0 
	        	order by LENGTH(cta_n.cuenta) desc 
	        loop
				--raise notice 'paso for 2';
	            if position(cuenta_padre.cuenta in cuenta_actual.cuenta) = 1 and LENGTH(cuenta_actual.cuenta) > LENGTH(cuenta_padre.cuenta) then
	                nivel_actual := cuenta_padre.nivel + 1;
	                cuenta_padre_actual := cuenta_padre.cuenta;
					--raise notice 'For 2 cuenta_padre:% nivel_actual:% cuenta_padre_actual:%, cuenta_actual actualizar:%',cuenta_padre.cuenta,nivel_actual,cuenta_padre_actual,cuenta_actual.cuenta;
	
	               exit;
	            end if;
	        end loop;
--raise exception 'cuenta_padre_actual %',cuenta_padre_actual;	
			--raise notice 'ACTUALIZA cuenta_actualizar:% cuenta_padre:% nivel_actual:% ',cuenta_actual.cuenta,cuenta_padre_actual,nivel_actual;
			if TG_OP = 'INSERT' and cuenta_actual.cuenta = new.c1 then
				select count(*) into intValor from keplersc.kdc2_view 
					where anio= anio_cuenta and c3 = cuenta_padre_actual;
				if intValor > 0 then
					raise exception 'La cuenta padre % tiene movimientos. No es posible agregar la cuenta %',cuenta_padre_actual, new.c1;
				end if;
			end if;
			if (TG_OP = 'UPDATE' and new.c1<>old.c1) and cuenta_actual.cuenta = new.c1 then
				select count(*) into intValor from keplersc.kdc2_view 
					where anio= anio_cuenta and c3 = cuenta_padre_actual;
				if intValor > 0 then
					raise exception 'La cuenta padre % tiene movimientos. No es posible agregar la cuenta %',cuenta_padre_actual, new.c1;
				end if;
			end if;
	        update keplersc.cuentas_niveles 
	       	set nivel = nivel_actual, cuenta_padre = cuenta_padre_actual 
	      		where anio = anio_cuenta and cuenta = cuenta_actual.cuenta;
	    end loop;
			
	end if;

	return new;
end;
$function$
