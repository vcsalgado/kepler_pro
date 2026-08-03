CREATE OR REPLACE FUNCTION keplersc.get_dscr_cuenta(cuenta text, anio text)
 RETURNS TABLE(resultado text, mensaje text, adicionales text)
 LANGUAGE plpgsql
AS $function$
declare
	--Descripcion: Obtiene la Descripcion de la Cta Contable del Parametro 
	--Autor: Jose Mendoza
	--Fecha: 20240404

	--Variables de retorno
	resultado text;
	mensaje text;
	adicionales text;

	--variables de uso general
	tabla_cuentas text = '';
	intValor int = 0;
	expSql text = '';
	dscr_cta text = '';

begin
	
	tabla_cuentas := 'keplersc.kdc1' || anio;

	--Validar que cuenta existe
	expSql := format('SELECT count(*) from %1$s where c1=%2$L',tabla_cuentas,cuenta);

	execute expSql into intValor;
	if intValor = 0 then --La cuenta no existe
		raise exception 'La cuenta % no existe.', cuenta;
	end if;	

	--Obtener Descripcion de la Cta 
	dscr_cta := '';

	expSql := format('SELECT c2 from %1$s where c1=%2$L',tabla_cuentas,cuenta);

	execute expSql into dscr_cta;
	
	dscr_cta := coalesce(dscr_cta,'');

	resultado := 1;
	mensaje := dscr_cta/*''*/;
	adicionales := '';
	return query select resultado, mensaje, adicionales;	

exception
	when others then
		resultado := 0;
		--mensaje := sqlerrm;
		mensaje := 'get_dscr_cuenta() ' || '['|| sqlstate || '] ' || sqlerrm;
		adicionales := '';
		return query select resultado, mensaje, adicionales;	
end;
$function$
