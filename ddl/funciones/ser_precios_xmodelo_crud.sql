CREATE OR REPLACE FUNCTION keplersc.ser_precios_xmodelo_crud(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
--Descripcion: Realiza actualización de precio por modelo en la tabla KDSPAQ
--Autor: Miriam Santana
--Fecha: 02/Feb/23
--Bitacora de cambios

	--Variables de definicion de documento
	marca_id text;
	modelo_id text;
	clave text;
	varios text;
	horas text;
	precio text;
	no_partidas int = 0;
	
	--Variables de uso general 
	strValor text = '';
	intValor int = 0;
	
	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
begin
	marca_id := (xpath('//document/k_marca/text()', dataxml))[1];
	modelo_id := (xpath('//document/k_modelo/text()',dataxml))[1];
	strValor:=coalesce((xpath('//document/k_partidas/no_partidas/text()', dataxml))[1],'0');
	no_partidas:=strValor::int;

	if marca_id is null then
		raise exception 'Falta seleccionar la marca';
	end if;
	if modelo_id is null then
		raise exception 'Falta seleccionar el modelo';
	end if;
		
	--Actualizar registros
	for cont in 0..no_partidas-1 loop
		clave:= (xpath('//document/k_mov/r' ||cont||'/k_clave/text()',dataxml))[1];
		varios:= coalesce((xpath('//document/k_mov/r' ||cont||'/k_varios/text()',dataxml))[1],'0');
		horas:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_horas/text()',dataxml))[1],'0');
		precio:=coalesce((xpath('//document/k_mov/r' ||cont||'/k_precio/text()',dataxml))[1],'0');

		if clave is not null or clave <> '' then			
			update keplersc.kdspaq set
				c8=varios::decimal,
				c9=horas::decimal,
				c10=precio::decimal
			where c1=marca_id and c2=modelo_id and c4=clave;
		end if;
	end loop;

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := 'ser_precios_xmodelo_crud() ' || '['|| sqlstate || '] ' || sqlerrm ;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
