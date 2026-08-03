CREATE OR REPLACE FUNCTION keplersc.autos_com_asig_rpt(dataxml xml)
 RETURNS TABLE(c_cveinv text, c_cvemod text, c_anio text, c_descrip text, c_serie text, c_color text, c_vest text, c_suc text)
 LANGUAGE plpgsql
AS $function$
declare

	--Variables de definicion de documento
	sucursal_id text = '';
	fech_oper text = '';
	tipo_auto text = '';

	-- Code Added 20221208 by JMM
	fech_I text = '';
	fech_F text = '';
	
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	expSql text = '';

	--Variables de retorno
	xmlResultado xml;

begin
	
	--/*
	sucursal_id := (xpath('//document/sucursal_id/text()', dataxml))[1];
	fech_oper := '';
	if xpath_exists('//document/fech_oper/text()', dataxml) = true /*false*/ then 
		fech_oper := (xpath('//document/fech_oper/text()', dataxml))[1];
	end if;
	tipo_auto := (xpath('//document/tipo_auto/text()', dataxml))[1];

	-- Code Added 20221208 by JMM
	fech_I := '';
	if xpath_exists('//document/fech_I/text()', dataxml) = true /*false*/ then 
		fech_I := (xpath('//document/fech_I/text()', dataxml))[1];
	end if;
	fech_F := '';
	if xpath_exists('//document/fech_F/text()', dataxml) = true /*false*/ then 
		fech_F := (xpath('//document/fech_F/text()', dataxml))[1];
	end if;

	--*/

	--raise notice 'Fechas % %', fech_ini , fech_fin;
	
	drop table if exists tmpRows;
	create temp table tmpRows (
		c_cveinv text, 
		c_cvemod text, 
		c_anio text, 
		c_descrip text, 
		c_serie text, 
		c_color text, 
		c_vest text, 
		c_suc text 
	);


	if xpath_exists('//document/fech_oper/text()', dataxml) = true /*false*/ then
	
		insert into tmpRows
		select c2 as invent, c3 as modelo, c15 as anio, c4 as descrip, c5 as serie, c10 as color, c11 as vest, c1 as suc /*, c24 as fech*/ 
		from keplersc.kdinf where c24 = to_date(fech_oper/*'2022-11-03'*/,'YYYY-MM-DD') and c31 = 10 and upper(c21) = tipo_auto  
		order by /*c24 desc,*/ right(c2,length(c2)-5) desc, left(c2,4) desc ;
	
	else 
	
		insert into tmpRows
		select c2 as invent, c3 as modelo, c15 as anio, c4 as descrip, c5 as serie, c10 as color, c11 as vest, c1 as suc /*, c24 as fech*/ 
		from keplersc.kdinf where c1 = sucursal_id and c31 = 10 and upper(c21) = tipo_auto  
			-- code Added 20221208 by JMM 
			and c24 >= case when length(fech_I) = 0 then to_date('1910-01-01','YYYY-MM-DD') else to_date(fech_I,'YYYY-MM-DD') end
			and c24 <= case when length(fech_F) = 0 then to_date('2099-12-31','YYYY-MM-DD') else to_date(fech_F,'YYYY-MM-DD') end
		order by /*c24 desc,*/ right(c2,length(c2)-5) desc, left(c2,4) desc ;
		
	end if;
	
	return query select * from tmpRows;

END;
$function$
