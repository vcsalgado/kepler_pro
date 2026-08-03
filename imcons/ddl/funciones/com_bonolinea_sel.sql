CREATE OR REPLACE FUNCTION keplersc.com_bonolinea_sel(dataxml xml)
 RETURNS TABLE(sucursal text, esquema text, anio text, mes text, linea text, descripcion text, bono numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	anio text = '';
	mes text = '';
	pasado text = '';
	strFecha text = '';
	fecha date;

	--Variables de proceso
	linea text;
	objetivo numeric(5) = 0;
	bono numeric(12,2) = 0.00;
	
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/r0/text()', dataxml))[1];
	anio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	mes := (xpath('//document/k_mes/r0/text()', dataxml))[1];
	pasado := (xpath('//document/k_pasado/r1/text()', dataxml))[1];
	anio:=substring(anio,3,2);

	drop table if exists tmpRows;
	create temp table tmpRows (
		_sucursal text, 
		_esquema text, 
		_anio text, 
		_mes text, 
		_linea text,
		_descripcion text,
		_bono numeric(12,2)
	);

	--Crear la tabla con los valores iniciales de lineas
	insert into tmpRows 
	select distinct sucursal_id, esquema, anio, mes, iv.c7, ivl.c2 ,0.00
	from keplersc.kdiv iv inner join keplersc.kdivl ivl
	on iv.c7=ivl.c1 where c11='S' and c7 <> '' order by c7;

	--Completar valores de objetivo e importe
	if pasado='S' then 		--obtener el ultimo periodo
		select c3, c4 into anio,mes from keplersc.kdvobjlinea
		where c3||c4 < anio||mes
		order by c4 desc,c5 desc limit 1;
	end if;

	for linea,bono 
		in select c5,c6 from keplersc.kdvobjlinea
		where c1 = sucursal_id and c2=esquema and c3=anio and c4=mes
	loop 
--raise notice 'anio:% mes:% linea:% esquema:% objetivo:% bono:%',anio,mes,linea,esquema,objetivo,bono;		
		update tmpRows set _bono=bono
		where _sucursal=sucursal_id	and _esquema=esquema and _linea=linea;
	end loop;
	

	return query select _sucursal as sucursal, _esquema as esquema,
		_anio as anio, _mes as mes, _linea as linea, 
		_descripcion as descripcion, _bono as bono
		from tmpRows order by _linea;

end;
$function$
