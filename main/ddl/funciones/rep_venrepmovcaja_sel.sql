CREATE OR REPLACE FUNCTION keplersc.rep_venrepmovcaja_sel(dataxml xml)
 RETURNS TABLE(polnum numeric, poltipmov text, polfech text, polref text, polsuc text, poldescr text, polfolio text, docdescr text, polmonto text)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal_ini text = '';
	sucursal_fin text = '';
	fech_ini text = '';
	fech_fin text = '';
	cta_cont text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	xmlReqDoctos text = '';
	expSql text = '';

	error text = '';
	str_anio text = '';
	str_mes_ini text = '';
	str_mes_fin text = '';
	int_mes_ini int = 0;
	int_mes_fin int = 0;
	tablakdc1 text = '';
	tablakdc2 text ='';
	totReg int = 0;
	cont int = 0;
	curTabla text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal_ini := (xpath('//document/sucursal_ini/text()', dataxml))[1];
	sucursal_fin := (xpath('//document/sucursal_fin/text()', dataxml))[1];
	fech_ini := (xpath('//document/fech_ini/text()', dataxml))[1];
	fech_fin := (xpath('//document/fech_fin/text()', dataxml))[1];
	cta_cont := (xpath('//document/cta_cont/text()', dataxml))[1];
	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpDoctos;
	create temp table tmpDoctos (
		polnum numeric,
		poltipmov text,
		polfech text,
		polref text,
		polsuc text, 
		poldescr text,
		polfolio text,
		docdescr text,
		polmonto text
	);


	str_anio := substring(fech_ini, 3, 2);
	str_mes_ini = substring(fech_ini, 6, 2);
	str_mes_fin = substring(fech_fin, 6, 2);
	int_mes_ini = str_mes_ini::int;
	int_mes_fin = str_mes_fin::int;

	--Verificar si existe la tabla kdc1 del anio seleccionado ... 
	tablakdc1 := concat('kdc1', str_anio);
	select count(*) into totReg from information_schema.tables 
	where table_name = tablakdc1;

	if totReg = 0 then
		raise exception 'No se tiene informacion contable para el a�o %, tabla(%)', substring(fecha_ini, 3, 2), tablakdc1;
	--else
	--	raise notice '% %', 'Tabla KDC1 ', tablakdc1;
	end if;


	--Verificar si existe(n) la(s) tabla(s) kdc2 del rango/periodo seleccionado ...
	for cont in int_mes_ini/*1*/ .. int_mes_fin/*int_mes_ini*/ loop
		curTabla := concat('kdc2', str_anio, lpad(cont::text,2,'0'));	
		select count(*) into totReg from information_schema.tables
		where table_name  = curTabla;
		if totReg = 0 then
			raise exception 'No se tiene informacion contable para la tabla del periodo %', curTabla;
			/*
			expSql:=format('insert into tmpkdc2 select * from keplersc.%1$s 
				where c3 >= %2$L and c3 <= %3$L and c2<%4$L'
				,curTabla,cuenta_ini,cuenta_fin,fecha_ini);
			execute expSql;
			*/
		--else
		--	raise notice '% %', 'Tabla KDC2 ', curTabla;
		end if;		
	end loop;


	--raise exception '%', 'Valido todas las Tablas para los PARAMs';

	strValor := 'YYYY-MM-DD';

	for cont in int_mes_ini/*1*/ .. int_mes_fin/*int_mes_ini*/ loop
	
		curTabla := concat('kdc2', str_anio, lpad(cont::text,2,'0'));


		expSql = format(
		'
		insert into tmpDoctos 
		select 
			T.c1 as polnum, T.c4 as poltipmov, T.c2 as polfech, T.c7 as polref, T.c14 as polsuc, left(T.c6, 35) as poldescr 
			, (T.c15 || T.c16 || lpad(T.c17::text,2,''0'') || lpad(T.c18::text,3,''0'') || ''-'' || T.c19) as polfolio 
			, left(M.C5, 20) as docdescr, T.c5 as polmonto  
		from keplersc.%6$s T 
		inner join keplersc.kdmm M on T.c14 = M.col_sucursal and T.c15 = M.c1 and T.c16 = M.c2 and T.c17 = M.c3 and T.c18 = M.c4 
		where T.c3 = %5$L  
			and ( T.c2 >= to_date(%3$L,%7$L) and T.c2 <= to_date(%4$L,%7$L) )
			and ( T.c14 >= %1$L and T.c14 <= %2$L )
		order by T.c2, T.c1, T.c4; 
		'
		,sucursal_ini, sucursal_fin, fech_ini, fech_fin, cta_cont, curTabla, strValor);
	
	
	
		expSql = format(
		'
		insert into tmpDoctos 
		select 
			T.c1 as polnum, T.c4 as poltipmov, T.c2 as polfech, T.c7 as polref, T.c14 as polsuc, left(T.c6, 35) as poldescr 
			, (T.c15 || T.c16 || lpad(T.c17::text,2,''0'') || lpad(T.c18::text,3,''0'') || ''-'' || T.c19) as polfolio 
			, left(M.C5, 20) as docdescr, T.c5 as polmonto  
		from keplersc.%6$s T 
		inner join keplersc.kdmm M on T.c14 = M.col_sucursal and T.c15 = M.c1 and T.c16 = M.c2 and T.c17 = M.c3 and T.c18 = M.c4 
		where T.c3 in (''200-002'',''201-002'',''201-003'',''203-001'')   
			and ( T.c2 >= to_date(%3$L,%7$L) and T.c2 <= to_date(%4$L,%7$L) )
			and ( T.c14 >= %1$L and T.c14 <= %2$L )
		order by T.c2, T.c1, T.c4; 
		'
		,sucursal_ini, sucursal_fin, fech_ini, fech_fin, '200-002,201-002,201-003,203-001', curTabla, strValor);	
	
	
		--*/
	
		--raise notice '%', expSql;
	
		execute expSql;

	end loop;
	
	-- expSql='insert into tmpDoctos select c1 as clave_prod, c2 as desc_prod, ''''::xml as folios from keplersc.kdini'; 
	--raise notice '%', expSql;
	--execute format(expSql);

	--raise notice '%', 'Paso FOR Insert(s)';

	return query select * from tmpDoctos order by polsuc, polfech, polnum;

exception
	when others then
		error := 'keplersc.rep_venrepmovcaja_sel() ' || '['|| sqlstate || '] ' || sqlerrm ;
		raise exception '%', error;	
	
END;
$function$
