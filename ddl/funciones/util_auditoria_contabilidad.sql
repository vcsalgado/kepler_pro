CREATE OR REPLACE PROCEDURE keplersc.util_auditoria_contabilidad()
 LANGUAGE plpgsql
AS $procedure$
declare 
	--Variables de definicion de documento
	criterio text = '';
	anio text = '';
	
	--Variables de proceso
	error text = '';
	recM2 record;
	tabla_cuentas text = '';
	expSql text = '';
	intValor int;

begin
	--Validacion que las cuentas de las polizas existan en el catalogo de cuentas
	for recM2 in select distinct v2.c3 from keplersc.kdc223_view v2 where v2.c3 not in 
		(select cat.c1 from keplersc.kdc124 cat where cat.c1=v2.c3) order by v2.c3
	loop
		raise notice 'No esta en kdc1: %',recM2.c3;
	end loop;

	anio='24';
	tabla_cuentas = 'keplersc.kdc1' || anio;
	--Validacion que las cuentas de las polizas sean de nivel mas bajo
	for recM2 in select distinct v2.c3 from keplersc.kdc223_view v2 order by v2.c3
	loop

		expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,recM2.c3);

		execute expSql into intValor;
		if intValor = 0 then --La cuenta no existe
			raise notice 'La cuenta % no existe.',recM2.c3;
		end if;	

		--Validar que la cuenta es de último nivel
		expSql = format('SELECT count(*) from %1$s where position(%2$L in c1) > 0 and substring(c1,1,length(%2$L)) = %2$L and c1<>%2$L',tabla_cuentas,recM2.c3);	
		execute expSql into intValor;
		if intValor > 0 then --no es cuenta del mas bajo nivel
			raise notice 'La cuenta % no es de último nivel.',recM2.c3;
		end if;	
	end loop;

	--Validacion que las cuentas de las polizas tengan un nivel mayor
	for recM2 in select distinct v2.c3 from keplersc.kdc223_view v2 order by v2.c3
	loop
		--Validar que la cuenta tiene un padre
		expSql = format('select count(*) from %1$s where position(c1 in %2$L) > 0 and substring(c1,1,1) = substring(%2$L,1,1) 
			and c1<>%2$L',tabla_cuentas,recM2.c3);
		execute expSql into intValor;
--raise exception '1. Sql: %, Valor:%', expSql,intValor;	
		if intValor = 0 then --
			raise notice '%', concat('falta cuenta de primer nivel %',recM2.c3);
		end if;	



		expSql = format('SELECT count(*) from %1$s where position(%2$L in c1) > 0 and substring(c1,1,length(%2$L)) = %2$L and c1<>%2$L',tabla_cuentas,recM2.c3);	
		execute expSql into intValor;
		if intValor > 0 then --no es cuenta del mas bajo nivel
			raise notice 'La cuenta % no es de último nivel.',recM2.c3;
		end if;	
	end loop;

	--Validacion que las cuentas de las polizas cuadren en el acumulado 

/*	
select * from
(select cuenta,
max(anio_22) as anio_22,sum(saldoMeses_ant_22) as saldoMeses_ant_22, sum(saldo_ini_22) as saldo_ini_22,sum(cargos_22) as cargos_22, sum(abonos_22) as abonos_22, sum(saldo_final_22) as saldo_final_22,
max(anio_23) as anio_23,sum(saldoMeses_ant_23) as saldoMeses_ant_23, sum(saldo_ini_23) as saldo_ini_23,sum(cargos_23) as cargos_23, sum(abonos_23) as abonos_23, sum(saldo_final_23) as saldo_final_23,
max(anio_24) as anio_24,sum(saldoMeses_ant_24) as saldoMeses_ant_24, sum(saldo_ini_24) as saldo_ini_24,sum(cargos_24) as cargos_24, sum(abonos_24) as abonos_24, sum(saldo_final_24) as saldo_final_24,
max(anio_25) as anio_25,sum(saldoMeses_ant_25) as saldoMeses_ant_25, sum(saldo_ini_25) as saldo_ini_25,sum(cargos_24) as cargos_25, sum(abonos_25) as abonos_25, sum(saldo_final_25) as saldo_final_25,
sum(saldo_ini_22) as saldo_ini_22, sum(saldoMeses_ant_22) as saldoMeses_ant_22, sum(cargos_22) - sum(abonos_22) as car_abo_22, sum(saldo_final_22) as saldo_final_22, 
sum(saldo_ini_23) as saldo_ini_23, sum(saldoMeses_ant_23) as saldoMeses_ant_23, sum(cargos_23) - sum(abonos_23) as car_abo_23, sum(saldo_final_23) as saldo_final_23,
sum(saldo_ini_24) as saldo_ini_24, sum(saldoMeses_ant_24) as saldoMeses_ant_24, sum(cargos_24) - sum(abonos_24) as car_abo_24, sum(saldo_final_24) as saldo_final_24,
sum(saldo_ini_25) as saldo_ini_25, sum(saldoMeses_ant_25) as saldoMeses_ant_25, sum(cargos_25) - sum(abonos_25) as car_abo_25, sum(saldo_final_25) as saldo_final_25,
sum(saldo_final_22)-sum(saldo_ini_23) as dif_ini_23, sum(cargos_22) - sum(abonos_22) - sum(saldoMeses_ant_23) as dif_movs_23,
sum(saldo_final_23)-sum(saldo_ini_24) as dif_ini_24, sum(cargos_23) - sum(abonos_23) - sum(saldoMeses_ant_24) as dif_movs_24,
sum(saldo_final_24)-sum(saldo_ini_25) as dif_ini_25, sum(cargos_24) - sum(abonos_24) - sum(saldoMeses_ant_25) as dif_movs_25
from
(select c1 as cuenta, '22' as anio_22,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant_22,
	sum(c14) as saldo_ini_22,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_22,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_22,
    sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_22,
    '' as anio_23, 0 as saldoMeses_ant_23, 0 as saldo_ini_23, 0 as cargos_23, 0 as abonos_23, 0 as saldo_final_23,
    '' as anio_24, 0 as saldoMeses_ant_24, 0 as saldo_ini_24, 0 as cargos_24, 0 as abonos_24, 0 as saldo_final_24,
    '' as anio_25, 0 as saldoMeses_ant_25, 0 as saldo_ini_25, 0 as cargos_25, 0 as abonos_25, 0 as saldo_final_25    
from keplersc.kdc122
--where length(c1) = 3
group by c1
union
select 
	c1 as cuenta, 
    '' as anio_22, 0 as saldoMeses_ant_22, 0 as saldo_ini_22, 0 as cargos_22, 0 as abonos_22, 0 as saldo_final_22,	
	'23' as anio_23,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant_23,
	sum(c14) as saldo_ini_23,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_23,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_23,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_23,
    '' as anio_24, 0 as saldoMeses_ant_24, 0 as saldo_ini_24, 0 as cargos_24, 0 as abonos_24, 0 as saldo_final_24,
    '' as anio_25, 0 as saldoMeses_ant_25, 0 as saldo_ini_25, 0 as cargos_25, 0 as abonos_25, 0 as saldo_final_25
from keplersc.kdc123
--where length(c1) = 3
group by c1
union
select 
	c1 as cuenta,
    '' as anio_22, 0 as saldoMeses_ant_22, 0 as saldo_ini_22, 0 as cargos_22, 0 as abonos_22, 0 as saldo_final_22,	
    '' as anio_23, 0 as saldoMeses_ant_23, 0 as saldo_ini_23, 0 as cargos_23, 0 as abonos_23, 0 as saldo_final_23,   
	'24' as anio_24,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant_24,
	sum(c14) as saldo_ini_24,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_24,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_24,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_24,
    '' as anio_25, 0 as saldoMeses_ant_25, 0 as saldo_ini_25, 0 as cargos_25, 0 as abonos_25, 0 as saldo_final_25
from keplersc.kdc124
--where length(c1) = 3
group by c1
union
select
	c1 as cuenta,
    '' as anio_22, 0 as saldoMeses_ant_22, 0 as saldo_ini_22, 0 as cargos_22, 0 as abonos_22, 0 as saldo_final_22,	
    '' as anio_23, 0 as saldoMeses_ant_23, 0 as saldo_ini_23, 0 as cargos_23, 0 as abonos_23, 0 as saldo_final_23,
    '' as anio_24, 0 as saldoMeses_ant_24, 0 as saldo_ini_24, 0 as cargos_24, 0 as abonos_24, 0 as saldo_final_24,    
	'25' as anio_25,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant_25,
	sum(c14) as saldo_ini_25,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_25,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_25,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_25
from keplersc.kdc125
--where length(c1) = 3 
group by c1
) as sub
group by cuenta order by cuenta) as sub2
where 1=1 
--and (dif_ini_23 <> 0 or dif_movs_23<>0 or dif_ini_24 <> 0 or dif_movs_24<>0 or dif_ini_25 <> 0 or dif_movs_25 <>0)
and cuenta collate "C" = '370';

*/
end;
$procedure$
