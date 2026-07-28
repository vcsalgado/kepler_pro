CREATE OR REPLACE FUNCTION keplersc.verify_cuenta_movtos_hijos(cuenta text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Indica el total de movimientos contables que la cuenta proporcionada tiene en algun nivel
	--inferior sin importar el año contable, revisa en todo el historial
	--Autor: Victor Salgado
	--Fecha: 30 Marzo 2023

	--Variables de retorno
	intValor int = 0;

begin
	select count(*) into intValor from keplersc.kdc2_view where c3 in(
		select c1 from keplersc.kdc1_view  where position(cuenta in c1) > 0 and substring(c1,1,1) = substring(cuenta,1,1) 
		and c1<>cuenta);
	
	return intValor;
end;
$function$
