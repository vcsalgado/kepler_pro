CREATE OR REPLACE FUNCTION keplersc.com_comisvariables_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion. Función para actualizar la tabla kdvargv 
	-- relacionada con comisiones
	--Autor: Victor Salgado
	--Fecha: 15 Enero 2023
	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	anio text = '';
	mes text = '';
	pasado text = '';
	no_partidas int = 0;
	strFecha text = '';
	fecha date;
	ns text = '';
	descripcion text = '';
	porcomis numeric(5,2) = 0.00;
	objetivo numeric(5,2) = 0.00;
	porresult numeric(5,2) = 0.00;

	--Variables de uso general 
	strValor text = '';
	intValor int = 0;

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	sucursal_id := (xpath('//document/k_sucn/r1/text()', dataxml))[1];
	esquema := (xpath('//document/k_esquema/r0/text()', dataxml))[1];
	mes := (xpath('//document/k_mes/r0/text()', dataxml))[1];
	anio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	pasado := (xpath('//document/k_pasado/r1/text()', dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	anio:=substring(anio,3,2);

	--Eliminar registrados asociados anio,mes y esquema
	delete from keplersc.kdvargv
		where c1=sucursal_id and c2=esquema and c3=mes and c4=anio;

	--Insertar nuevos registros
	for cont in 0..no_partidas loop
		ns:= (xpath('//document/k_mov/r' ||cont||'/k_t_ns/text()',dataxml))[1];		
		descripcion:= (xpath('//document/k_mov/r' ||cont||'/k_t_descripcion/text()',dataxml))[1];
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_t_porcomis/text()',dataxml))[1],'0');
		porcomis:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_t_objetivo/text()',dataxml))[1],'0');
		objetivo:=strValor::numeric;
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_t_resultado/text()',dataxml))[1],'0');
		porresult:=strValor::numeric;
	
		insert into keplersc.kdvargv
			(c1,c2,c3,c4,c5,c6,c7,c8,c9,c10)
		values(sucursal_id,esquema,mes,anio,cont+1,
			ns,descripcion,porcomis,objetivo,porresult);
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_comisvariables_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
