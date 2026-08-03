CREATE OR REPLACE FUNCTION keplersc.verify_gastos(cuenta text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Verifica que la cuenta no este como un gasto
	--Autor: Victor Salgado
	--Fecha: 23 Ago 2022

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	intValor int = 0;
	expSql text = '';
begin
	
	select count(*) into intValor from keplersc.kdcatgastos k 
	where c3=cuenta or c5=cuenta or c7=cuenta or c9=cuenta or c11=cuenta;
	
	if intValor > 0 then --La cuenta tiene gastos 
		raise exception 'La cuenta % tiene gastos relacionados.',cuenta;
	end if;	

	resultado := 1;
	mensaje := '';
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		mensaje := sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
