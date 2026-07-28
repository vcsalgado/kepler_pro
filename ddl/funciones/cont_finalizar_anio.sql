CREATE OR REPLACE FUNCTION keplersc.cont_finalizar_anio(anio_old integer, anio_new integer)
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

	--Actualizar saldos iniciales de cada una de las cuentas
	expSql:=format('update keplersc.%1$s set c14 = c14+c27+c28+c29+c30+c31+c32+c33+c34+c35+c36+c37+c38
		-c63-c64-c65-c66-c67-c68-c69-c70-c71-c72-c73-c74',kdc1_new);
raise notice 'Saldos ini: %',expSql;
	execute expSql;

	--Actualizar saldos meses anio anterior
	for cont in 0..11 loop
		campo_mes:=concat('c',(15+cont)::text);
		campo_cargo:=concat('c',(27+cont)::text);
		campo_abono:=concat('c',(63+cont)::text);
		expSql=format('update keplersc.%1$s set %2$s=%3$s-%4$s',kdc1_new, campo_mes,campo_cargo, campo_abono);
raise notice 'Saldo mes: %',expSql;	
		execute expSql;
	end loop;

	--Reset a campos de meses nuevos
	for cont in 0..11 loop
		campo_cargo:=concat('c',(27+cont)::text);
		campo_abono:=concat('c',(63+cont)::text);
		expSql=format('update keplersc.%1$s set %2$s=0, %3$s=0',kdc1_new, campo_cargo, campo_abono);
raise notice 'Reset mes: %',expSql;	
		execute expSql;
	end loop;

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

	--Cuentas de taller

	insert into keplersc.kdtallcont 
	select c1,c2, lpad(anio_new::text,2,'0'), c4,c5,c6,c7,c8,
	c9,c10,c11,c12,c13,c14,c15,c16,c17,c18
	from keplersc.kdtallcont where c3=lpad(anio_old::text,2,'0');


	insert into keplersc.kdivcl 
	select c1,lpad(anio_new::text,2,'0'),c3,c4,c5,c6,c7,c8,
	c9,c10,c11,c12,c13,c14,c15,c16,c17,c18,
	c19,c20,c21,c22,c23,c24,c25,c26
	from keplersc.kdivcl where c2=lpad(anio_old::text,2,'0');

--Agregar registro en kddinv

--Agregar registro en kdym

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

/*--Auditoria de proceso
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
