CREATE OR REPLACE FUNCTION keplersc.proceso_finalizar_anio(anio_old integer, anio_new integer)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Fucion que genera las tablas para el nuevo anio
	--Autor: Victor Salgado
	--Fecha: 02/01/2023
--kdivcl, kddinv
--kdtallcont
--
	--Variables de definicion de documento
	variable_id text = '';	

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	kdc1_old text = '';
	kdc1_new text = '';
	kdc2_old text = '';
	kdc2_new text = '';
	expSql text ='';
	cont int = 0;
	campo_cargo text='';
	campo_abono text='';
	campo_mes text='';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	kdc1_old:=format('kdc1%1$s',anio_old);
	kdc1_new:=format('kdc1%1$s',anio_new);

	--Eliminar tabla de cuentas del anio nuevo
	expSql= format('drop table if exists keplersc.%1$s',kdc1_new);
raise notice 'Eliminar: %',expSql;
	execute expSql;

	--crear tabla del anio nuevo
	expSql= format('create table keplersc.%1$s as table keplersc.kdc1 ',kdc1_new);
raise notice 'Crear kdm1: %',expSql;
	execute expSql;


	--Insertar registros iniciales 
	expSql=format('insert into keplersc.%1$s select * from keplersc.%2$s',kdc1_new,kdc1_old);
raise notice 'Inciales: %',expSql;
	execute expSql;

	update keplersc.kdc124 set c14=0.00,c15=0.00,c16=0.00,c17=0.00,
		c18=0.00,c19=0.00,c20=0.00,c21=0.00,c22=0.00,c23=0.00,c24=0.00,c25=0.00,c26=0.00;
	
	--Reset a campos de meses nuevos
	for cont in 0..11 loop
		campo_cargo:=concat('c',(27+cont)::text);
		campo_abono:=concat('c',(63+cont)::text);
		expSql=format('update keplersc.%1$s set %2$s=0, %3$s=0',kdc1_new, campo_cargo, campo_abono);
raise notice 'Reset mes: %',expSql;	
		execute expSql;
	end loop;

	--Actualizar saldos meses anio anteriores cuentas que no son de resultados
	update keplersc.kdc124 as a set c15=coalesce((select c27-c63 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c16=coalesce((select c28-c64 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c17=coalesce((select c29-c65 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c18=coalesce((select c30-c66 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c19=coalesce((select c31-c67 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c20=coalesce((select c32-c68 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c21=coalesce((select c33-c69 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c22=coalesce((select c34-c70 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c23=coalesce((select c35-c71 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c24=coalesce((select c36-c72 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c25=coalesce((select c37-c73 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 as a set c26=coalesce((select c38-c74 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);	
	
	update keplersc.kdc124 as a set c14=coalesce((select c14 from keplersc.kdc123 b where b.c1=a.c1 and b.c1<'400'),0);
	update keplersc.kdc124 set c14=c14+c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26;

	--Actualizar saldos para cuenta de resultados
/*
	update keplersc.kdc124 as a set c14=coalesce((select sum(c14) as c14 from keplersc.kdc123 b where b.c1>='400' and b.c1 not like '%380%'),0);
	update keplersc.kdc124 set c14=sum(c14+c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26);
*/
	--Creacion de tablas de movimientos mensuales
	for cont in 1..12 loop
		kdc2_new:=concat('kdc2',anio_new::text,lpad((cont::text),2,'0'));		
		--Eliminar tabla 
		expSql= format('drop table if exists keplersc.%1$s',kdc2_new);	
raise notice 'Eliminando tabla mensual: %',expSql;	
		execute expSql;
		--Crear tabla
		expSql=format('create table keplersc.%1$s as table keplersc.kdc2',kdc2_new);
raise notice 'Creando tabla mensual: %',expSql;	
		execute expSql;
	end loop;		

	ALTER TABLE keplersc.kdc124 ADD CONSTRAINT pk_kdc124 PRIMARY KEY (c1);
	CREATE UNIQUE INDEX pk_kdc124 ON keplersc.kdc124 USING btree (c1);
	CREATE INDEX sindkdc12402 ON keplersc.kdc124 USING btree (c2, c1);
	CREATE INDEX sindkdc12403 ON keplersc.kdc124 USING btree (c3, c1);

	ALTER TABLE keplersc.kdc22402 ADD CONSTRAINT pk_kdc22402 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22402 ADD CONSTRAINT pk_kdc22402 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22403 ADD CONSTRAINT pk_kdc22403 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22404 ADD CONSTRAINT pk_kdc22404 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22405 ADD CONSTRAINT pk_kdc22405 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22406 ADD CONSTRAINT pk_kdc22406 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22407 ADD CONSTRAINT pk_kdc22407 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22408 ADD CONSTRAINT pk_kdc22408 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22409 ADD CONSTRAINT pk_kdc22409 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22410 ADD CONSTRAINT pk_kdc22410 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22411 ADD CONSTRAINT pk_kdc22411 PRIMARY KEY (c3, c2, c8, c1, c10);
	ALTER TABLE keplersc.kdc22412 ADD CONSTRAINT pk_kdc22412 PRIMARY KEY (c3, c2, c8, c1, c10);

	create trigger kdc22401_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22401 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22402_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22402 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22403_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22403 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22404_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22404 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22405_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22405 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22406_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22406 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22407_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22407 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22408_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22408 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22409_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22409 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22410_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22410 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22411_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22411 for each row execute function keplersc.cont_upd_saldos();
	create trigger kdc22412_upd_saldos_after_crud after insert or delete or update on keplersc.kdc22412 for each row execute function keplersc.cont_upd_saldos();
	
	INSERT INTO keplersc.sqliov (c1, c2, c3, c4, c5, c6) VALUES('POLIZAI2401', 0, 0, '0', 'kdc22401', 'c1');
	INSERT INTO keplersc.sqliov (c1, c2, c3, c4, c5, c6) VALUES('POLIZAE2401', 0, 0, '0', 'kdc22401', 'c1');
	INSERT INTO keplersc.sqliov (c1, c2, c3, c4, c5, c6) VALUES('POLIZAD2401', 0, 0, '0', 'kdc22401', 'c1');
	
	
	--Actualizacion de cuentas contables
	insert into keplersc.kdivcl
	select c1,'24',c3,c4,c5,c6,c7,c8,c9,c10,
	c11,c12,c13,c14,c15,c16,c17,c18,c19,c20,
	c21,c22,c23,c24,c25,c26
	from keplersc.kdivcl v1 where c2 in ('23') 
	and c1 not in 
	(select c1 from keplersc.kdivcl v2 where v2.c1=v1.c1 and v2.c2='24');
	
--	select c1,c2 from keplersc.kdivcl v2 where v2.c2 in ('23') order by c1,c2;


	--Actualizacion cuentas contables taller
	insert into keplersc.kdtallcont 
	select c1,c2, '24', c4,c5,c6,c7,c8,
	c9,c10,c11,c12,c13,c14,c15,c16,c17,c18
	from keplersc.kdtallcont where c3='23';

--	select * from keplersc.kdtallcont k where c3='24'

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	



/*--Auditoria de proceso
 
 select 
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_22,
	sum(c14) as saldo_ini_23,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_23,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_23,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_23
from keplersc.kdc123
where c1<'400';

select 
	sum(c15+c16+c17+c18+c19+c20+c21+c22+c23+c24+c25+c26) as saldoMeses_23,
	sum(c14) as saldo_ini_24,
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38) as cargos_24,
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as abonos_24,	
	sum(c14)+
	sum(c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38)-
    sum(c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74) as saldo_final_24
from keplersc.kdc124
where c1<'400';

 
select sum(saldo_ini), sum(cargos_anio), sum(abonos_anio), sum(saldo_fin)
from
(select saldo_ini, cargos_anio, abonos_anio, saldo_ini+cargos_anio-abonos_anio as saldo_fin
from
(select c14 as saldo_ini, 
c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38 as cargos_anio,
+c63+c64+c65+c66+c67+c68+c69+c70+c71+c72+c73+c74 as abonos_anio
from keplersc.kdc122 group by c1) as mensual) as saldo_anual
*/
exception
	when others then
		resultado := 0;
		mensaje := 'base_function() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
