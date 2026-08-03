CREATE OR REPLACE FUNCTION keplersc.verify_cuenta_saldo_hijos(cuenta text)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Indica el total de cuentas hijas  de la cuenta proporcionada 
	--que tienen saldo inicial
	--Autor: Victor Salgado
	--Fecha: 30 Marzo 2023

	--Variables de retorno
	intValor int = 0;

begin
		select count(c1) into intValor from keplersc.kdc1_view  where position(cuenta in c1) > 0 and 
			substring(c1,1,length(cuenta)) = cuenta and c1<>cuenta and c14>0;
	
	return intValor;
end;
$function$
