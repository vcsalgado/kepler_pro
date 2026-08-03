CREATE OR REPLACE FUNCTION keplersc.verify_cuenta_movtos_hijos(cuenta text, anio_oper text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Indica el total de movimientos contables que la cuenta proporcionada tiene en algun nivel
	--superior del que depende para el anio proporcionado
	--Autor: Victor Salgado
	--Fecha: 02/10/2025

	--Variables de retorno
	intValor int = 0;

begin
select count(*) into intValor from keplersc.kdc2_view where /*anio=anio_oper and */ c3 in(
		select c1 from keplersc.kdc1_view  where /*anio=anio_oper and*/ position(cuenta in c1) > 0 and substring(c1,1,length(cuenta)) = cuenta 
		and c1<>cuenta);
	
	return intValor;
end;
$function$
