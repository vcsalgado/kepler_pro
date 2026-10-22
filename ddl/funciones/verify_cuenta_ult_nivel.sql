CREATE OR REPLACE FUNCTION keplersc.verify_cuenta_ult_nivel(cuenta text, anio integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
  --Clon de verify_cuenta_ult_nivel
  --Ajustada para funcionar directamente en un query
	--variables de uso general
	tabla_cuentas text = '';
	intValor int = 0;
	expSql text = '';
begin
	tabla_cuentas = 'keplersc.kdc1' || anio;
	--Validar que cuenta existe
	expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta);


	execute expSql into intValor;
	if intValor = 0 then --La cuenta no existe
		return false;
	end if;	

	--Validar que la cuenta es de último nivel
	expSql = format('SELECT count(*) from %1$s where position(%2$L in c1) > 0 and substring(c1,1,1) = substring(%2$L,1,1)',tabla_cuentas,cuenta);

	execute expSql into intValor;
	if intValor > 1 then --no es cuenta del mas bajo nivel
		return false;
	end if;	

	return true;
end;
$function$
