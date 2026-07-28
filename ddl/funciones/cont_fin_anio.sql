CREATE OR REPLACE FUNCTION keplersc.cont_fin_anio(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Pasar los saldos finales de una año como iniciales de otro, inicia cuentas de resultados
	--Autor: Victor Salgado
	--Fecha: 09 Feb 2024

	--Variables de uso general 

	kdc1_campo_base_saldo_ini int = 14;
	kdc1_campo_base_aniomes_anterior int = 15;
	kdc1_campo_base_cargos int = 27;
	kdc1_campo_base_abonos int = 63;
	kdc1_col_saldo_aniomes_anterior text= '';
	kdc1_col_cargos text = '';
	kdc1_col_abonos text = '';
	tabla_kdc2 text = '';
	expSql text = '';
	campo_cuentas text = '';
	poliza numeric = 0;
	fecha timestamp;
	cuenta varchar(20) = '';
	asiento varchar(1);
	monto numeric(15,2);
	tipo varchar(1);
	mes int;
	cont int = 0;
	cta_upd record;
	fec_ini timestamp;
	fec_fin timestamp;
	totCargos numeric = 0.00;
	totAbonos numeric = 0.00;
	movtos int;

	tabla_ctas_anterior text = '';
	existeAnioAnt int;

	strValor text = ''; 
	intValor int = 0;
	tabla_kdc1 text = '';
	anio_ini int;
	anio_fin int;
	cuentares_prim text = '';
	cuentares_ult text = '';
	cuentautil_ant text = '';
	totalResultados decimal =0.00;
	totalAcumulado decimal=0.00;
	cuentaUtilMayAnt text = '';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
--	raise exception 'NO AUTORIZADO';
	-------------------------------------
	--Copia de saldos 
	-------------------------------------
	strValor:= coalesce((xpath('//document/k_anio_c/r0/text()', dataxml))[1]::text,'0')::text;
	anio_ini:=coalesce(strValor::int,0);
	strValor:= coalesce((xpath('//document/k_anio_d/r0/text()', dataxml))[1]::text,'0')::text;
	anio_fin:=coalesce(strValor::int,0);
	cuentares_prim:= coalesce((xpath('//document/k_cuentares_prim/text()', dataxml))[1]::text,'0')::text;
	cuentares_ult:= coalesce((xpath('//document/k_cuentares_ult/text()', dataxml))[1]::text,'0')::text;
	cuentautil_ant:= coalesce((xpath('//document/k_cuentautil_ant/text()', dataxml))[1]::text,'0')::text;
	cuentaUtilMayAnt:=substring(cuentautil_ant,1,3);

	if cuentares_prim = '0' then
		raise exception 'Error, sin primera cuenta de resultados.';
	end if;
	if cuentares_ult = '0' then
		raise exception 'Error, sin ultima cuenta de resultados.';
	end if;
	if cuentautil_ant = '0' then
		raise exception 'Error, sin cuenta de utilidad.';
	end if;
--raise exception 'Función no disponible';
	if anio_ini<21 then
		raise exception 'Error en el año a cerrar.';
	end if;
	anio_fin = anio_ini +1;

	tabla_ctas_anterior:=concat('kdc1',(anio_ini)::text);
	tabla_kdc1:=concat('kdc1',(anio_fin)::text);
	select count(*) into intValor from information_schema.tables 
	where upper(table_schema) ='KEPLERSC' and upper(table_name)=upper(tabla_kdc1);
	if intValor = 0 then
		raise exception 'No existe catálogo de cuentas del nuevo año.';
	end if;

	select count(*) into existeAnioAnt from information_schema.tables 
	where upper(table_schema) ='KEPLERSC' and upper(table_name)=upper(tabla_ctas_anterior);
	if existeAnioAnt = 0 then
		raise exception 'No existe catálogo de cuentas del año a cerrar.';
	end if;

	--Deshabilitar trigger
	expSql:=concat('ALTER TABLE keplersc.', tabla_kdc1, ' DISABLE TRIGGER kdc1_upd_nivel_after_crud');
	execute expSql;

	--Se tiene una tabla previa al anio base, se tomaran de saldos iniciales
	--Agregar cuentas faltantes que finalizaron con saldo, solo agregar la cuenta con 0 en los campos
	--numericos
	expSql=format('insert into keplersc.%1$s select c1, c2 from (select * from keplersc.%2$s a 
	where a.c1 not in (select b.c1 from keplersc.%1$s b where b.c1=a.c1)) as fl
	where fl.c14+fl.c27+fl.c28+fl.c29+fl.c30+fl.c31+fl.c32+fl.c33+fl.c34+fl.c35+fl.c36+fl.c37+fl.c38 -
	(fl.c63+fl.c64+fl.c65+fl.c66+fl.c67+fl.c68+fl.c69+fl.c70+fl.c71+fl.c72+fl.c73+fl.c74)<>0',
			tabla_kdc1,tabla_ctas_anterior);
raise notice 'Insertando cuentas faltantes con saldo %',expSql;			
	execute expSql;


	--Inicial en cero saldos iniciales de cada una de las cuentas
	expSql=format('update keplersc.%1$s set c14=0.00,c15=0.00,c16=0.00,c17=0.00,
	c18=0.00,c19=0.00,c20=0.00,c21=0.00,c22=0.00,c23=0.00,c24=0.00,c25=0.00,c26=0.00',tabla_kdc1);
raise notice 'paso 1 %',expSql;
	execute expSql;

	for cont in 1..12 loop
		--Actualizar saldos meses anio anterior
		expSql=format('update keplersc.%1$s as a set c%4$s=coalesce((select c%5$s-c%6$s from keplersc.%2$s b 
			where b.c1=a.c1 and b.c1<%3$L and b.c1<>%7$L and b.c1<>%7$L),0)',
			tabla_kdc1,tabla_ctas_anterior,cuentares_prim,cont+14,cont+26,cont+62,cuentautil_ant,cuentaUtilMayAnt);	
raise notice 'paso 2 %',expSql;				
		execute expSql;
	end loop;

	--Actualizar saldo inicial del anio con el del anio anterior
	expSql=format('update keplersc.%1$s as a set c14=coalesce((select c14 from keplersc.%2$s b where b.c1=a.c1 and b.c1<%3$L),0)',
			tabla_kdc1,tabla_ctas_anterior,cuentares_prim);
raise notice 'paso 3 %',expSql;				
	execute expSql;

	--Actualizar saldo del anio con el de inicial del anio anterior mas entradas y salidas mensuales del anio anterior
	expSql=format('update keplersc.%1$s as a set c14=c14+c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26',
					tabla_kdc1);
raise notice 'paso 4 %',expSql;				
	execute expSql;	


	--Obtener total del saldo de cuentas de resultados del anio anterior
	expSql=format('select sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38-
		c63-c64-c65-c66-c67-c68-c69-c70-c71-c72-c73-c74) from keplersc.%1$s 
		where  length(c1)=3 and c1>=%2$L and c1<=%3$L',
		tabla_ctas_anterior,cuentares_prim,cuentares_ult);	
raise notice '5. Calculando total de resultados anio anterior %',expSql;
	execute expSql into totalResultados;

	--Obtener total del saldo de cuentas de resultados del anio anterior

	expSql=format('select sum(c14)+sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74)
		from keplersc.%1$s 
		where length(c1)=3 and c1=%2$L',
		tabla_ctas_anterior,cuentaUtilMayAnt);	
raise notice '6. Obteniendo acumulado anio anterior %',expSql;
	execute expSql into totalAcumulado;	

	if totalAcumulado is null then
		totalAcumulado:=0;
	end if;

	totalResultados:=totalResultados+totalAcumulado;
--raise exception 'Total Acumulado: %',totalAcumulado;
	--Registrar el total del saldo de cuentas de resultados del anio anterior 
	-- la cuenta menor de utilidades acumuladas del nuevo año
	expSql=format('update keplersc.%1$s set c14=%2$s,
		c15=0,c16=0,c17=0,c18=0,c19=0,c20=0,c21=0,c22=0,c23=0,c24=0,c25=0,c26=0 
		where c1=%3$L',tabla_kdc1,totalResultados,cuentautil_ant);
raise notice '7. Registrando utilidad ejercicios anteriores niv menor %',expSql;	
	execute expSql;	
	
	--Registrar el total del saldo de cuentas de resultados del anio anterior 
	--a la cuenta mayor de utilidades acumuladas del nuevo año 
	expSql=format('update keplersc.%1$s set c14=%2$s,
		c15=0,c16=0,c17=0,c18=0,c19=0,c20=0,c21=0,c22=0,c23=0,c24=0,c25=0,c26=0
		where c1=%3$L',tabla_kdc1,totalResultados,cuentaUtilMayAnt);
raise notice '8. Registrando utilidad ejercicios anteriores niv mayor %',expSql;
	execute expSql;	

	--Habilitar trigger
	expSql:=concat('ALTER TABLE keplersc.', tabla_kdc1, ' ENABLE TRIGGER kdc1_upd_nivel_after_crud');
	execute expSql;

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
	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		--Habilitar trigger
		if tabla_kdc1 <> '' then
			expSql := concat('create trigger kdc1_upd_nivel_after_crud after insert or delete or update on keplersc.', tabla_kdc1 ,' for each row execute function keplersc.cont_upd_nivel()');
			execute expSql;
		end if;
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
