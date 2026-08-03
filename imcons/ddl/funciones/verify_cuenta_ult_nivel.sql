CREATE OR REPLACE FUNCTION keplersc.verify_cuenta_ult_nivel(dataxml xml)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Verifica que la cuenta proporcionada sea de ultimo nivel
	--Autor: Victor Salgado
	--Fecha: 23 Ago 2022

	cuenta text=''; 
	anio text='';

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;
	
	--variables de uso general
	tabla_cuentas text = '';
	desc_cuenta text = '';
	intValor int = 0;
	expSql text = '';
begin

	cuenta := (xpath('//document/cuenta/text()', dataxml))[1]; 
	anio := coalesce((xpath('//document/anio/text()', dataxml))[1]::text,'')::text;

	tabla_cuentas = 'keplersc.kdc1' || anio;
	--Validar que cuenta existe
	expSql = format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta);

	execute expSql into intValor;
	if intValor = 0 then --La cuenta no existe
		raise exception 'La cuenta % no existe.',cuenta;
	end if;	

	expSql = format('SELECT c2 from %1$s where c1=%2$L',tabla_cuentas,cuenta);

	execute expSql into desc_cuenta;

	--Validar que la cuenta es de último nivel
	expSql = format('SELECT count(*) from %1$s where position(%2$L in c1) > 0 and substring(c1,1,length(%2$L)) = %2$L and c1<>%2$L',tabla_cuentas,cuenta);

	execute expSql into intValor;
	if intValor > 1 then --no es cuenta del mas bajo nivel
		raise exception 'La cuenta % no es de último nivel.',cuenta;
	end if;	


	resultado := 1;
	mensaje := desc_cuenta;
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
