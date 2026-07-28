CREATE OR REPLACE FUNCTION keplersc.calculadora(dataxml xml)
 RETURNS TABLE(k_historial text, k_numero_1 numeric, k_operador text, k_numero_2 numeric, k_resultado numeric)
 LANGUAGE plpgsql
AS $function$

declare 
	--Variables de definicion de documento
	k_historial text = '';
	k_numero_1 numeric(18,2) = 0.00;
	k_operador text = 'meh';
	k_numero_2 numeric(18,2) = 0.00;
	

	--Variables de proceso
	k_resultado numeric(12,2) = 0.00;

begin
	k_historial := (xpath('//document/k_historial/text()', dataxml))[1];
	k_numero_1 := (xpath('//document/k_numero_1/text()', dataxml))[1];
	k_operador := (xpath('//document/k_operador/text()', dataxml))[1];
	k_numero_2 := (xpath('//document/k_numero_2/text()', dataxml))[1];
	if k_operador='*' then 
		k_resultado := (k_numero_1 * k_numero_2);
	elsif k_operador='/' then
		k_resultado := (k_numero_1 / k_numero_2);
	elsif k_operador='+' then
		k_resultado := (k_numero_1 + k_numero_2);
	elsif k_operador='-' then
		k_resultado := (k_numero_1 - k_numero_2);
    end if;
	
   k_historial := concat(k_numero_1, k_operador, k_numero_2 );
	

	drop table if exists tmpCalc;
	create temp table tmpCalc (
		_K_historial text, 
        _k_numero_1 numeric(18,2),
        _k_operador text,
        _k_numero_2 numeric(18,2),
        _k_resultado numeric(18,2)
	);

	--Crear la tabla 
   -- update tmpCalc set _k_historial=k_historial, _k_numero_1=k_numero_1,
   -- _k_operador=k_operador, _k_numero_2=k_numero_2;
	INSERT INTO tmpCalc (_k_historial , _k_numero_1, _k_operador, _k_numero_2, _k_resultado)
	VALUES (k_historial, k_numero_1, k_operador, k_numero_2, k_resultado);

	return query select _k_historial as k_historial, _k_resultado as k_numero_1,
		_k_operador as k_operador, _k_numero_2 as k_numero_2, _k_resultado as k_resultado
		from tmpCalc;

end;
$function$
