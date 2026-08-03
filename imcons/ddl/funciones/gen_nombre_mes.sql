CREATE OR REPLACE FUNCTION keplersc.gen_nombre_mes(mesnumero integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
	resultado text = '';
begin
	select
	case 
		when mesnumero = 1 then 'Enero'
		when mesnumero = 2 then 'Febrero'
		when mesnumero = 3 then 'Marzo'
		when mesnumero = 4 then 'Abril'
		when mesnumero = 5 then 'Mayo'
		when mesnumero = 6 then 'Junio'
		when mesnumero = 7 then 'Julio'
		when mesnumero = 8 then 'Agosto'
		when mesnumero = 9 then 'Septiembre'
		when mesnumero = 10 then 'Octubre'
		when mesnumero = 11 then 'Noviembre'
		when mesnumero = 12 then 'Diciembre'
		else ''
	end into resultado;
	return resultado;
end
$function$
