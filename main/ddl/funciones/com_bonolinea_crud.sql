CREATE OR REPLACE FUNCTION keplersc.com_bonolinea_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion. Función para actualizar la tabla kdvobjlinea
	-- relacionada con comisiones
	--Autor: Victor Salgado
	--Fecha: 19 Enero 2023
	--Variables de definicion de documento
	sucursal_id text = '';
	esquema text = '';
	anio text = '';
	mes text = '';
	pasado text = '';
	no_partidas int = 0;
	strFecha text = '';
	fecha date;
	linea text;
	objetivo numeric(5) = 0;
	bono numeric(12,2) = 0.00;


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
	anio := (xpath('//document/k_anio/r0/text()', dataxml))[1];
	mes := (xpath('//document/k_mes/r0/text()', dataxml))[1];
	pasado := (xpath('//document/k_pasado/r1/text()', dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;
	anio:=substring(anio,3,2);

	--Eliminar registrados asociados anio,mes y esquema
	delete from keplersc.kdvobjlinea  
		where c1=sucursal_id and c2=esquema and c3=anio and c4=mes;

	--Insertar nuevos registros
	for cont in 0..no_partidas loop
		linea:= (xpath('//document/k_mov/r' ||cont||'/k_t_linea/text()',dataxml))[1];
		strValor:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_t_bono/text()',dataxml))[1],'0');
		bono:=strValor::numeric;			
		insert into keplersc.kdvobjlinea(c1,c2,c3,c4,c5,c6)
			values(sucursal_id,esquema,anio,mes,linea,bono);
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'com_bonolinea_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
