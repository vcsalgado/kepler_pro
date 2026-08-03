CREATE OR REPLACE FUNCTION keplersc.cont_actualizar_saldos(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Recalcula los saldos para un anio y mes dado, en su correspondiente tabla
	--kdc2 y los saldos acumulados de ese periodo en adelante

	--Variables de uso general 
	strValor text = ''; 
	intValor int = 0;
	tabla_kdc1 text = '';
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
	ctas record;
	cta_upd record;
	fec_ini timestamp;
	fec_fin timestamp;
	totCargos numeric = 0.00;
	totAbonos numeric = 0.00;
	movtos int;
	anio_ini int;
	tabla_ctas_anterior text = '';
	existeAnioAnt int;
	cont_anio int;
	anio_proceso int;
	anio_fin int;
	cuentares_prim text = ''; --'400';
	cuentares_ult text = ''; --'899';
	cuentautil_ant text = ''; --'380-001';
	cuentaUtilMayAnt text = ''; --'380';
	totalResultados numeric =0.00;
	totalAcumulado numeric = 0.00;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	get_resultado text;
	get_mensaje text;
	get_adicionales text;
begin
--	raise exception 'NO AUTORIZADO';
	-------------------------------------
	--Recreacion de saldos 
	-------------------------------------
	strValor := coalesce((xpath('//document/k_anio/r1/text()', dataxml))[1]::text,'0')::text;
	anio_ini:=coalesce(strValor::int,0);
	if anio_ini=0 then
		raise exception 'No se especificó el año inicial';
	end if;
	if length(strValor) > 2 then
		mensaje:=concat('Error en formato de año (yy), recibido: ',anio_ini);
		raise exception '%', mensaje;
	end if;
	select extract('Year' from current_date)-2000 into anio_fin;

	--Obtener cuentas
	select c4 into cuentares_prim from keplersc.sqliov where c1='CUENTAS' and c2=12;
	if cuentares_prim is null then
		raise exception 'Sin cuenta primaria de resultados'; 
	end if;

	select c4 into cuentares_ult from keplersc.sqliov where c1='CUENTAS' and c2=21;
	if cuentares_ult is null then
		raise exception 'Sin ultima cuenta de resultados'; 
	end if;

	select valor into cuentautil_ant from keplersc.param_oper where parametro='Cuenta Utildad Anterior';
	if cuentautil_ant is null then
		raise exception 'Sin cuenta de utilidad del ejercicio anterior'; 
	end if;
	cuentaUtilMayAnt:=substring(cuentautil_ant,1,3);
raise notice 'cuentares_prim:% ,cuentares_ult:% ,cuentautil_ant:% , cuentaUtilMayAnt:%  ',cuentares_prim,cuentares_ult,cuentautil_ant,cuentaUtilMayAnt;

	for cont_anio in anio_ini..anio_ini loop
		tabla_ctas_anterior:=concat('kdc1',(cont_anio-1)::text);
		tabla_kdc1:=concat('kdc1',(cont_anio)::text);
		select count(*) into intValor from information_schema.tables 
		where upper(table_schema) ='KEPLERSC' and upper(table_name)=upper(tabla_kdc1);
		if intValor = 0 then
			continue;
		end if;

		expSql:=concat('ALTER TABLE keplersc.', tabla_kdc1, ' DISABLE TRIGGER kdc1_upd_nivel_after_crud');
		execute expSql;
	
		select count(*) into existeAnioAnt from information_schema.tables 
		where upper(table_schema) ='KEPLERSC' and upper(table_name)=upper(tabla_ctas_anterior);
		/*Seccion saldos iniciales*/
		if existeAnioAnt > 0 then
			--Se tiene una tabla previa al anio base, se tomaran de saldos iniciales
			--Agregar cuentas faltantes que finalizaron con saldo		
			expSql=format('insert into keplersc.%1$s select * from (select * from keplersc.%2$s a 
			where a.c1 not in (select b.c1 from keplersc.%1$s b where b.c1=a.c1)) as fl
			where fl.c14+fl.c27+fl.c28+fl.c29+fl.c30+fl.c31+fl.c32+fl.c33+fl.c34+fl.c35+fl.c36+fl.c37+fl.c38 -
			(fl.c63+fl.c64+fl.c65+fl.c66+fl.c67+fl.c68+fl.c69+fl.c70+fl.c71+fl.c72+fl.c73+fl.c74)<>0',
			tabla_kdc1,tabla_ctas_anterior);
raise notice 'Insertando cuentas faltantes con saldo %',expSql;			
			execute expSql;			
		end if;

		expSql=format('update keplersc.%1$s set 
			c27=0,c28=0,c29=0,c30=0,c31=0,c32=0,c33=0,c34=0,c35=0,c36=0,c37=0,c38=0,
			c63=0,c64=0,c65=0,c66=0,c67=0,c68=0,c69=0,c70=0,c71=0,c72=0,c73=0,c74=0',tabla_kdc1);
raise notice 'Iniciando saldos %',expSql;
		execute expSql;	

	
		/*Seccion actualizacion de cuentas*/

		for ctas in execute format('select * from keplersc.%1$s order by c1', tabla_kdc1)
		loop
raise notice 'Procesando tabla: % Cuenta: %',tabla_kdc1,ctas.c1;			
			fec_ini:=concat('20',cont_anio,'-01-01 00:00')::timestamp;
			fec_fin:=concat('20',cont_anio,'-01-31 23:59')::timestamp;
			movtos=0;
			for cont in 1..12 loop
				expSql=format('select coalesce(sum(c5),0) from keplersc.kdc2%1$s_view 
					where c3=%2$L and c4=%3$L and c2>=%4$L and c2<=%5$L',
					cont_anio,ctas.c1,'C',fec_ini,fec_fin);
				execute expSql into totCargos;
				expSql=format('select coalesce(sum(c5),0) from keplersc.kdc2%1$s_view 
					where c3=%2$L and c4=%3$L and c2>=%4$L and c2<=%5$L',
					cont_anio,ctas.c1,'A',fec_ini,fec_fin);
				execute expSql into totAbonos;
				if totCargos<>0 or totAbonos<>0 then
					movtos:=1;
				end if;
				if cont=1 then
					ctas.c27=totCargos;
					ctas.c63=totAbonos;
				end if;
				if cont=2 then
					ctas.c28=totCargos;
					ctas.c64=totAbonos;
				end if;
				if cont=3 then
					ctas.c29=totCargos;
					ctas.c65=totAbonos;
				end if;
				if cont=4 then
					ctas.c30=totCargos;
					ctas.c66=totAbonos;
				end if;
				if cont=5 then
					ctas.c31=totCargos;
					ctas.c67=totAbonos;
				end if;
				if cont=6 then
					ctas.c32=totCargos;
					ctas.c68=totAbonos;
				end if;
				if cont=7 then
					ctas.c33=totCargos;
					ctas.c69=totAbonos;
				end if;
				if cont=8 then
					ctas.c34=totCargos;
					ctas.c70=totAbonos;
				end if;
				if cont=9 then
					ctas.c35=totCargos;
					ctas.c71=totAbonos;
				end if;
				if cont=10 then
					ctas.c36=totCargos;
					ctas.c72=totAbonos;
				end if;
				if cont=11 then
					ctas.c37=totCargos;
					ctas.c73=totAbonos;
				end if;
				if cont=12 then
					ctas.c38=totCargos;
					ctas.c74=totAbonos;
				end if;		
				fec_ini:=fec_ini + interval '1 month';
				fec_fin:=fec_ini + interval '1 month' - interval '1 day' + interval '86399 seconds';
			end loop;
			if movtos=1 then
				--Actualiza cuenta
				expSql=format('update keplersc.%1$s set c27=c27+%2$s, c28=c28+%3$s, c29=c29+%4$s,
					c30=c30+%5$s, c31=c31+%6$s, c32=c32+%7$s, c33=c33+%8$s, c34=c34+%9$s, c35=c35+%10$s,
					c36=c36+%11$s, c37=c37+%12$s, c38=c38+%13$s,
	  				c63=c63+%14$s, c64=c64+%15$s, c65=c65+%16$s,
					c66=c66+%17$s, c67=c67+%18$s, c68=c68+%19$s, c69=c69+%20$s, c70=c70+%21$s, c71=c71+%22$s,
					c72=c72+%23$s, c73=c73+%24$s, c74=c74+%25$s
					where position(c1 in %26$L) = 1 returning 1::text ',tabla_kdc1, ctas.c27,
					ctas.c28,ctas.c29,ctas.c30,ctas.c31,ctas.c32,ctas.c33,ctas.c34,ctas.c35,ctas.c36,ctas.c37,ctas.c38,
					ctas.c63,ctas.c64,ctas.c65,ctas.c66,ctas.c67,ctas.c68,ctas.c69,ctas.c70,ctas.c71,ctas.c72,ctas.c73,ctas.c74,
					ctas.c1);
				execute expSql into intValor;			
			end if;				
		end loop;
		--Habilitar trigger
		expSql:=concat('ALTER TABLE keplersc.', tabla_kdc1, ' ENABLE TRIGGER kdc1_upd_nivel_after_crud');
		execute expSql;
	end loop;

	--Pasar lo saldos de un mes a otro desdde el anio de regeneraccion de saldos hasta el actual
	if anio_fin > anio_ini then
		for cont_anio in anio_ini..anio_fin-1 loop
			if anio_fin > cont_anio then
				expSql=format('<document>
				<k_anio_c>%1$s<r0>%1$s</r0></k_anio_c>
				<k_anio_d>%2$s<r0>%2$s</r0></k_anio_d>
				<k_cuentares_prim>%3$s</k_cuentares_prim>
				<k_cuentares_ult>%4$s</k_cuentares_ult>
				<k_cuentautil_ant>%5$s</k_cuentautil_ant>
				</document>',cont_anio::text,(cont_anio+1)::text,cuentares_prim,cuentares_ult,cuentaUtilMayAnt);
raise notice '%',expSql;
				SELECT * into get_resultado, get_mensaje, get_adicionales FROM keplersc.cont_fin_anio(expSql::xml);
			end if;
		end loop;
	end if;
	
/*	
--Auditoria de proceso
select '22' as anio,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant,
	sum(c14) as saldo_ini,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos,
    sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final
from keplersc.kdc122
where length(c1) = 3 
union
select 
	'23' as anio,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant,
	sum(c14) as saldo_ini,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final
from keplersc.kdc123
where length(c1) = 3
union
select 
	'24' as anio,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant,
	sum(c14) as saldo_ini,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final
from keplersc.kdc124
where length(c1) = 3
--group by c1;
union
select
	'25' as anio,
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_ant,
	sum(c14) as saldo_ini,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final
from keplersc.kdc125
where length(c1) = 3;


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
			expSql:=concat('ALTER TABLE keplersc.', tabla_kdc1, ' ENABLE TRIGGER kdc1_upd_nivel_after_crud');
			execute expSql;
		end if;
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	

end;
$function$
