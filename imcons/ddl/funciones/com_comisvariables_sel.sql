CREATE OR REPLACE FUNCTION keplersc.com_comisvariables_sel(dataxml xml)
 RETURNS TABLE(sucursal text, esquema text, mes text, anio text, consecutivo numeric, ns text, descripcion text, porcomis numeric, objetivo numeric, resultado numeric)
 LANGUAGE plpgsql
AS $function$
declare 
	--Descripcion: Funcion que regresa los registros de la tabla kdvargv relacionada con 
	--comisiones variables
	--Autor: Victor Salgado
	--Fecha: 17 Enero 2023

	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	anio text = '';
	mes text = '';
	pasado text = '';
	strFecha text = '';
	fecha date;

	--Variables de proceso
	intTotal int = 0; 
	
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/r0/text()', dataxml))[1];
	anio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	mes := (xpath('//document/k_mes/r0/text()', dataxml))[1];
	pasado := (xpath('//document/k_pasado/r1/text()', dataxml))[1];
	anio:=substring(anio,3,2);

raise notice 'sucursal_id:% esquema:% mes:% anio:%',sucursal_id,esquema,mes,anio;

	--Obtener anio y mes a presentar
	if pasado='S' then 		--obtener el ultimo periodo
		select count(*) into intTotal from keplersc.kdvargv;
		if intTotal>0 then
			select c4, c3 into anio,mes from keplersc.kdvargv k 
			where c4||c3 < anio||mes
			order by c4 desc,c5 desc limit 1;
		end if;
	end if;

	return query select c1::text as sucursal, c2::text as esquema, c3::text as mes, c4::text as anio, 
		c5 as consecutivo, c6::text as ns, c7::text as descripcion, c8 as porcomis, 
		c9 as objetivo, c10 as resultado
		from keplersc.kdvargv where c1=sucursal_id and c2=esquema and c3=mes and c4=anio order by c5;

end;
$function$
