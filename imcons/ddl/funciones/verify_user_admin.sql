CREATE OR REPLACE FUNCTION keplersc.verify_user_admin(usuario text)
 RETURNS TABLE(resultado text, mensaje text)
 LANGUAGE plpgsql
AS $function$
DECLARE
	--Variables
	perfilAdmin text;
	regTotal integer;
	mensaje text;
	resultado text;
	expSql text;
begin
	resultado := '1';
	mensaje := '';
	--Validar usuario
	perfilAdmin := '';
    select c5 into perfilAdmin from keplersc.kdusrinfo k where c1 = usuario;

	if perfilAdmin is null OR perfilAdmin = '' then
		mensaje := 'No se encuentra al usuario, Operacion no permitida';
		resultado := '0';
	else
		if perfilAdmin = 'S' then
			mensaje := 'Tiene privilegios de Administrador, no divulgue su password';
			resultado := '1';
		else
			resultado := '0';
		end if;
	end if;
	return query select resultado, mensaje;
		
END;
$function$
