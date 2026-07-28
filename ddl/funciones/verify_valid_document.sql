CREATE OR REPLACE FUNCTION keplersc.verify_valid_document(genero text, naturaleza text, grupo integer, tipo_movto integer)
 RETURNS TABLE(resultado text, mensaje text)
 LANGUAGE plpgsql
AS $function$
declare 
--variables
documento_no_valido text;
mensaje text;
resultado text;

--Variables de retorno
registro record;

BEGIN
	mensaje := '';
	documento_no_valido := 'N';
	resultado := '1';

	select
		case when c90 is null then 'N' else c90 end as c90
	into documento_no_valido 
	from keplersc.kdmm 
	where c1=genero and c2=naturaleza and c3=grupo and c4=tipo_movto;

	if documento_no_valido is null then
		mensaje := 'Documento no definido, operacion no permitida';
		resultado := '0';
	end if;

	if resultado = '1' then
		if documento_no_valido = 'S' then
			mensaje := 'El movimiento fue invalidado por el Departamento de Sistemas","No se pueden hacer Altas ni Bajas, Solo Consultas';
			resultado := '0';
		end if;
	end if;
	
	return query select resultado, mensaje;
END;
$function$
