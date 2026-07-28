CREATE OR REPLACE FUNCTION keplersc.rep_venrepcajtotxtpcbrfto_ords_sel(dataxml xml)
 RETURNS TABLE(tipo text, orden text, fecha text, usuario text, motivo text)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal_ini text = '';
	sucursal_fin text = '';
	fech_ini text = '';
	fech_fin text = '';

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal_ini := (xpath('//document/sucursal_ini/text()', dataxml))[1];
	sucursal_fin := (xpath('//document/sucursal_fin/text()', dataxml))[1];
	fech_ini := (xpath('//document/fech_ini/text()', dataxml))[1];
	fech_fin := (xpath('//document/fech_fin/text()', dataxml))[1];
	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpRows;
	create temp table tmpRows (
		tipo text, 
		orden text, 
		fecha text, 
		usuario text, 
		motivo text 
	);


	/*
	insert into tmpRows
	select c2, c3, c5, c4, c6 from keplersc.kdordceros  
	where 
		( c5 >= to_date(fech_ini/*'2022-04-01'*/,'YYYY-MM-DD') and c5 <= to_date(fech_fin/*'2022-04-30'*/,'YYYY-MM-DD') )
		and ( c1 >= sucursal_ini and c1 <= sucursal_fin )
	order by c1, c5;  
	*/

	insert into tmpRows
	select /*c1,*/ c2, c3, c5, c4, c6 from keplersc.kdordceros  
	where 
		( c5 >= to_date(fech_ini,'YYYY-MM-DD') and c5 <= to_date(fech_fin,'YYYY-MM-DD') )
		and ( c1 >= sucursal_ini and c1 <= sucursal_fin )
		and (c3 || c2 || c1) in (
			select tr.MaxOrd from (
				select c3, max(c3 || c2 || c1) as MaxOrd from keplersc.kdordceros 
				where 
					( c5 >= to_date(fech_ini,'YYYY-MM-DD') and c5 <= to_date(fech_fin,'YYYY-MM-DD') )
					and ( c1 >= sucursal_ini and c1 <= sucursal_fin )
				group by c3 
			) tr 
		)
	order by c1, c5;
	
	return query select * from tmpRows;

END;
$function$
