CREATE OR REPLACE FUNCTION keplersc.verify_year(fecha text)
 RETURNS TABLE(resultado text, mensaje text)
 LANGUAGE plpgsql
AS $function$
DECLARE
	--Variables
	anio text;
	mes text;
	dia text;
	mesInt integer;
	regTotal integer;
	mensaje text;
	resultado text;
	expSql text;
begin
	resultado := '1';
	mensaje := '';
--	fecha := fecha(replace(fecha,'-','/'));
	anio := split_part(fecha,'/', 3);
	mes := split_part(fecha,'/', 2);
	dia := split_part(fecha,'/', 1);
	mesInt := cast(mes as integer);
	mesInt = mesInt + 9; --Los meses inician en el campo 10
	--Validar año
	expSql := 'SELECT COUNT(*) FROM keplersc.kdym WHERE c1 = ''' ||
	anio || ''' and c' || cast(mesInt as text) || ' = ''A''';
	execute expSql into regTotal;
	
	if regTotal = 0 then
		mensaje := 'EL MES YA ESTA CERRADO EN CONTABILIDAD, 
			COMUNIQUESE A CONTABILIDAD PARA PODER REALIZAR LA OPERACION';
		resultado := '0';
	end if;

	return query select resultado, mensaje;
		
END;
$function$
