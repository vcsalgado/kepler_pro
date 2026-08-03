CREATE OR REPLACE FUNCTION keplersc.full_replace(datatx text, char_from text, char_to text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
--Descripcion: Se obtiene el producto original dada una clave
--Autor: Jose Mendoza
--Fecha: 11/01/2024
--Bitacora de cambios
declare
	data_base text;
	data_depured text;
	data_result text;
	totReg int =0;

begin
	
	data_base := datatx;
	data_depured := regexp_replace(data_base, char_from, char_to);
	
	if data_base <> data_depured then
		select keplersc.full_replace(data_depured, char_from, char_to) into data_result;
	else
		data_result := data_depured;
	end if;

	return data_result;
end;
$function$
