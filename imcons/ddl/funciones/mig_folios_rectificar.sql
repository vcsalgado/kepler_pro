CREATE OR REPLACE FUNCTION keplersc.mig_folios_rectificar()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	numValor numeric = 0;
	expSql text = '';
	_tabla text = '';
	_colSuc text = '';
	_colGen text = '';
	_colNat text = '';
	_colGpo text = '';
	_colTip text = '';
	_colFol text = '';
	_indicenombre text = '';
	_indicedef text = '';
	totRegistros int =0;

	--Variables de retorno
	resultado text;

begin

--*************************
--1. Crear registros en sqliov y hacer conversion de folio
--*************************	
/*	
	--Tabla sqliov, para subaru el campo de sqlikov c4 es 10 caracteres
	--y se observa que el folio mayor no rebasa los 7 csaracteres
	update keplersc.sqliov set c4=lpad(substring(c4,3),7,'0') where c2=0 and c3=0 and c1 <> 'CUENTAS';
	--Insertar contadores relacionados con telemarketing, citas y ordenes, polizas
	select max(c2) into strValor from keplersc.kdtmktser2;
	numValor := strValor;
	numValor := numValor + 1000;
	strValor:=numValor::text;
	strValor:=lpad(strValor,10,'0');
	--Utilizar el folio 3000
	insert into keplersc.sqliov (c1,c2,c3,c4) values ('TMKT.01',0,0,'0000003000');
	
	--Verficar siguiente consecutivo,
	--Depurar registros co consecutivo alto de ordenes
	--select max(c3) from keplersc.kdord where not substring(c3,1,1) ~ '^[A-Z]+$' 
	--Hay folios salteados, utilizar 3200
	insert into keplersc.sqliov (c1,c2,c3,c4) values ('ORDENES.01',0,0,'0000003000');	

	select coalesce(max(c1),0) into intValor from keplersc.kdc22212 
	where c8='D';
	strValor:=intValor::text;
	strValor:=lpad(strValor,7,'0');
	insert into keplersc.sqliov (c1,c2,c3,c4) values ('POLIZAD2212',0,0,strValor);

	select coalesce(max(c1),0) into intValor from keplersc.kdc22212 
	where c8='I';
	strValor:=intValor::text;
	strValor:=lpad(strValor,7,'0');
	insert into keplersc.sqliov (c1,c2,c3,c4) values ('POLIZAI2212',0,0,strValor);

	select coalesce(max(c1),0) into intValor from keplersc.kdc22212 
	where c8='E';
	strValor:=intValor::text;
	strValor:=lpad(strValor,7,'0');
	insert into keplersc.sqliov (c1,c2,c3,c4) values ('POLIZAE2212',0,0,strValor);
	
	update keplersc.sqliov set c5='', c6='' where c1='CUENTAS';
	update keplersc.sqliov set c5='kdm1', c6='c6' where c1<>'CUENTAS';
	update keplersc.sqliov set c5='kdctasser', c6='c2' where c1='CITAS.01';
	update keplersc.sqliov set c5='kdord', c6='c3' where c1='ORDENES.01';
	update keplersc.sqliov set c5='kdtmktser2', c6='c2' where c1='TMKT.01';
	update keplersc.sqliov set c5='kdc22212', c6='c1' where c1='POLIZAE2212';
	update keplersc.sqliov set c5='kdc22212', c6='c1' where c1='POLIZAI2212';
	update keplersc.sqliov set c5='kdc22212', c6='c1' where c1='POLIZAD2212';	
*/
--*************************
--FIN 1.
--*************************	

	
	
	
--*************************
--2. Recrear folios en tablas
--*************************
/*	
	--Recrear folio de tablas
	--Tabla tmporal para manejo de indices
--	drop table if exists tmpIndices;
--	create table tmpIndices(
--		indicenombre text not null,
 --  		indicedef text not null
--	);

	--Marcar registros a procesar
	update keplersc.mig_datos_rectificacion 
		set refol = 'N';
	update keplersc.mig_datos_rectificacion 
		set refol = 'S'
		where colsucursal<>'' and colfolio<>'' and coltipo<>'' and colgpo<>''
		and colnat<>'';
	--Procesar registros
	totRegistros := 0;
	for _tabla, _colSuc, _colGen, _colNat, _colGpo, _colTip, _colFol in 
		select tabla, colsucursal, colgen, colnat, colgpo, coltipo, colfolio 
		from keplersc.mig_datos_rectificacion re where upper(re.refol) = 'S'
		order by _tabla
	loop 
		totRegistros:=totRegistros+1;
		--Iniciar temporales
--		truncate tmpindices;
	
		--Obtener indices de la tabla
--		insert into tmpindices
--		(select indexname, indexdef 
--			from pg_indexes where tablename = _tabla);

		
		--Eliminar indices para eficientar el proceso
--		for _indicenombre in select indicenombre from tmpindices
--		loop
--			expSql:=format('drop index keplersc.%1$s',_indicenombre);
--			execute expSql;
--		end loop;

		_tabla =replace(_tabla,'_','');
		--Verificar que longitud del campo folio sea de 10 caracteres
		select character_maximum_length into intValor 
			from information_schema.columns
			where table_schema  = 'keplersc'
			and table_name = _tabla 
			and column_name = _colFol;
		
		if intValor < 10 then
			expSql = format('alter table keplersc.%1$s alter column %2$s type character varying(10);',_tabla, _colFol);
			execute expSql;
			--raise notice 'Modifcando tabla %',expSql;
		end if; 

		
		-- Sin caracteres en folio
		expSql:=format('update keplersc.%1$s set %2$s = %3$L || lpad(%2$s,7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and %2$s ~ %7$L',
			_tabla,_colFol,'VXX','0',_colSuc,'01','^\d+(\.\d+)?$');
raise notice '1 %',expSql;
		execute expSql;

		expSql:=format('update keplersc.%1$s set %2$s = %3$L || lpad(%2$s,7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and %2$s ~ %7$L',
			_tabla,_colFol,'SXX','0',_colSuc,'02','^\d+(\.\d+)?$');		
raise notice '2 %',expSql;
		execute expSql;

		expSql:=format('update keplersc.%1$s set %2$s = (%5$s::int)::text || %3$L || lpad(%2$s,7,%4$L) 
			where length(%2$s) = 7 and %5$s not in(%8$L, %6$L) and %2$s ~ %7$L',
			_tabla,_colFol,'XX','0',_colSuc,'02','^\d+(\.\d+)?$','01');		
raise notice '3 %',expSql;
		execute expSql;

		--Primer carater letra, segundo numero
		expSql:=format('update keplersc.%1$s set %2$s = %3$L || substring(trim(%2$s),1,1) || %8$L || 
			lpad(substring(%2$s,2),7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and not substring(%2$s,1,1) ~ %7$L and 
			substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'V','0',_colSuc,'01','^\d+(\.\d+)?$','X');
raise notice '4 %',expSql;
		execute expSql;
	
		expSql:=format('update keplersc.%1$s set %2$s = %3$L || substring(trim(%2$s),1,1) || %8$L || 
			lpad(substring(%2$s,2),7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and not substring(%2$s,1,1) ~ %7$L and 
			substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'S','0',_colSuc,'02','^\d+(\.\d+)?$','X');
raise notice '5 %',expSql;
		execute expSql;
	
		expSql:=format('update keplersc.%1$s set %2$s = (%5$s::int)::text || substring(trim(%2$s),1,1) || %8$L || 
			lpad(substring(%2$s,2),7,%4$L) 
			where length(%2$s) = 7 and %5$s not in(%9$L, %6$L) and not substring(%2$s,1,1) ~ %7$L and 
			substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'S','0',_colSuc,'02','^\d+(\.\d+)?$','X','01');
raise notice '6 %',expSql;
		execute expSql;

		--Segundo caracter numero
		expSql:=format('update keplersc.%1$s set %2$s = %3$L || substring(trim(%2$s),1,2) || 
			lpad(substring(%2$s,3),7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and not substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'V','0',_colSuc,'01','^\d+(\.\d+)?$');		
raise notice '7 %',expSql;
		execute expSql;
	
		expSql:=format('update keplersc.%1$s set %2$s = %3$L || substring(trim(%2$s),1,2) || 
			lpad(substring(%2$s,3),7,%4$L) 
			where length(%2$s) = 7 and %5$s = %6$L and not substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'S','0',_colSuc,'02','^\d+(\.\d+)?$');		
raise notice '8 %',expSql;
		execute expSql;
	
		expSql:=format('update keplersc.%1$s set %2$s = (%5$s::int)::text || substring(trim(%2$s),1,2) || 
			lpad(substring(%2$s,3),7,%4$L) 
			where length(%2$s) = 7 and %5$s not in(%8$L, %6$L) and not substring(%2$s,2,1) ~ %7$L',
			_tabla,_colFol,'S','0',_colSuc,'02','^\d+(\.\d+)?$','01');		
		execute expSql;
raise notice '9 %',expSql;

		--Regenerar indices
--		for _indicedef in select indicedef from tmpindices
--		loop
--			expSql:=_indicedef;
--			--raise notice 'Creando indice: %', expSql;
--			execute expSql;
--		end loop;

raise notice 'Procesados: %', totRegistros;	
	end loop;	
raise notice 'Total Procesados: %', totRegistros;

--Procesamiento de tablas de excepcion
raise notice 'Procesando tablas excepciones';
update keplersc.kduxg 
set c4 = case when c1='01' then 'V' when c1='02' then 'S' end || substring(c4,1,2) || '00' || substring(c4,3) 
where c2='U' and length(c4)=7 and substring(c4,1,2) ~ '^[A-Z].*$';

update keplersc.kduxe set c3=case when c1='01' then 'V' || substring(c3,1,2) || '00' || substring(c3,3) 
when c1='02' then 'S' || substring(c3,1,2) || '00' || substring(c3,3) end
where c5='U'
--Revisar resultado en caso de inconsistencia, este querie podría corregir:
--update keplersc.kduxe set c3= substring(c3,1,1)|| substring(c3,3,1)|| substring(c3,6) where c5='U' 
************KDM5, campo 14 VALIDAR 
select c6,c14,substring(c6,1,1) || substring(c14,1,2) ||'00' || substring(c14,3) as nuevo
from keplersc.kdm5 where 
	((c2='U' and c3='A' and c4=29 and c5=1) or
	(c2='U' and c3='A' and c4=29 and c5=2) or
	(c2='U' and c3='A' and c4=29 and c5=3) or
	(c2='U' and c3='A' and c4=29 and c5=4) or
	(c2='U' and c3='A' and c4=29 and c5=5) or
	(c2='U' and c3='A' and c4=32 and c5=1) or
	(c2='U' and c3='A' and c4=32 and c5=2) or
	(c2='U' and c3='A' and c4=32 and c5=3) or
	(c2='U' and c3='A' and c4=32 and c5=4) or
	(c2='U' and c3='D' and c4=13 and c5=1)) and length(c14) = 7;
	
update keplersc.kdm5 set c14 = substring(c6,1,1) || substring(c14,1,2) ||'00' || substring(c14,3)
where ((c2='U' and c3='A' and c4=29 and c5=1) or
	(c2='U' and c3='A' and c4=29 and c5=2) or
	(c2='U' and c3='A' and c4=29 and c5=3) or
	(c2='U' and c3='A' and c4=29 and c5=4) or
	(c2='U' and c3='A' and c4=29 and c5=5) or
	(c2='U' and c3='A' and c4=32 and c5=1) or
	(c2='U' and c3='A' and c4=32 and c5=2) or
	(c2='U' and c3='A' and c4=32 and c5=3) or
	(c2='U' and c3='A' and c4=32 and c5=4) or
	(c2='U' and c3='D' and c4=13 and c5=1)) and length(c14) = 7;
**************************

update keplersc.kdf3header set c13 = case when c1='01' then 'V'||c13 when c1='02' then 'S'||c13 end;
raise notice 'Fin tablas excepciones';
*/
--*************************
--FIN 2.
--*************************

--*************************
--3. Agregar registros adicionles
--*************************
/*	
INSERT INTO keplersc.kdf3uso VALUES ('P01', 'POR DEFINIR', 'SI', 'SI', '2022-01-01 00:00:00', '1990-01-01 00:00:00');
UPDATE keplersc.kdmm SET c5='OTROS ANTICIPOS' WHERE c1='U' AND c2='D' AND c3=79 AND c4=6;
update keplersc.kdmm set c21 = '324-003' where c1 = 'X' and c2 = 'A' and c3 = 7 and c4 = 2;
truncate keplersc.kddinv;
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('21',    'AUTOS NUEVOS 2021', '2021', 'IRN',    '21', 1, 'N');
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('22',    'AUTOS NUEVOS 2022', '2022', 'IRN',    '22', 1, 'N');
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U21', 'AUTOS USADOS 2021', '2021', 'IRU', '21', 1, 'U');
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U22', 'AUTOS USADOS 2022', '2022', 'IRU', '22', 1, 'U');
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('23',    'AUTOS NUEVOS 2023', '2023', 'IRN',    '23', 1, 'N');
insert into keplersc.kddinv (c1,c2,c3,c4,c5,c6,c7) values('U23', 'AUTOS USADOS 2023', '2023', 'IRU', '23', 1, 'U');
*/
--*************************
--3. FIN Agregar registros adicionles
--*************************


--*************************
--4. Actualizacion de sucursales
--*************************
/*
	--Actualizar sucursal a 01
	
	--Tabla kdms de sucursales
	delete from keplersc.kdms where c1='02';
	update keplersc.kdms set c2= 'SUBARU CONSTITUYENTES';
	
	--Se excluyen tablas que tendrian conflicto en la migracion
	totRegistros := 0;	
	for _tabla, _colSuc in 
		select tabla, colsucursal  
		from keplersc.mig_datos_rectificacion re 
		where colsucursal <>''
		and tabla not like '%\_%'
		and tabla not in('kdkcaja','kdord','kdordfent','kdpun','kdtord',
		'kdcfdsersucdoc','kduxg')
		order by _tabla
	loop 
	totRegistros := totRegistros + 1;		
		expSql = format('update keplersc.%1$s set %2$s = %3$L',_tabla,_colSuc,'01');		
raise notice '% , Actualizando Sucursal %',totRegistros, expSql;
		execute expSql;
	end loop;	
raise notice 'Total Procesados: %', totRegistros;
*/

--Excepciones encontradas	
--select * from keplersc.kduxg k  where c2='X' and  c3='D100012' and c4='0000000010' and c5=1;
--select * from keplersc.kduxg k  where c2='X' and  c3='D100171' and c4='0000000928' and c5=1;
--select * from keplersc.kduxg k  where c2='X' and  c3='D100171' and c4='0000000929' and c5=1;
--select * from keplersc.kduxg k  where c2='X' and  c3='D100012' and c4='0000000104' and c5=1;
--select * from keplersc.kduxg k  where c2='X' and  c3='D100713' and c4='A000000358' and c5=1;
--select * from keplersc.kduxg k  where c2='X' and  c3='D100405' and c4='R000010588' and c5=1;

/*
--Actualizacion de las tablas con problemas en los registros
update keplersc.kduxg set c1='01' 
	where not (c2='X' and  c3='D100012' and c4='0000000010' and c5=1)
	and not (c2='X' and  c3='D100171' and c4='0000000928' and c5=1)
	and not (c2='X' and  c3='D100171' and c4='0000000929' and c5=1)
	and not (c2='X' and  c3='D100012' and c4='0000000104' and c5=1)
	and not (c2='X' and  c3='D100713' and c4='A000000358' and c5=1)
	and not (c2='X' and  c3='D100405' and c4='R000010588' and c5=1);

update keplersc.kdord set c1='03' where c1='01';
update keplersc.kdord set c1='01' where c1='02';
update keplersc.kdordfent set c1='03' where c1='01';
update keplersc.kdordfent set c1='01' where c1='02';
update keplersc.kdpun set c1='03' where c1='01';
update keplersc.kdpun set c1='01' where c1='02';
update keplersc.kdtord set c1='03' where c1='01';
update keplersc.kdtord set c1='01' where c1='02';

*/
--*************************
--FIN 4.
--*************************

	resultado := 'Proceso terminado';
	return resultado;
end;
$function$
