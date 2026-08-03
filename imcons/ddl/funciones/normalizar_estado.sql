CREATE OR REPLACE FUNCTION keplersc.normalizar_estado(texto_input text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    resultado TEXT;
    t_limpio TEXT;
BEGIN
    IF texto_input IS NULL OR trim(texto_input) = '' THEN
        RETURN texto_input;
    END IF;

    t_limpio := upper(unaccent(trim(texto_input)));

    SELECT estado_canonico INTO resultado
    FROM keplersc.cat_estados_match
    WHERE t_limpio ~* ('^' || patron_regex || '$') 
       OR t_limpio ~* patron_regex
    ORDER BY prioridad ASC, length(patron_regex) DESC
    LIMIT 1;

    IF resultado IS NOT NULL THEN
        RETURN resultado;
    ELSE
        RETURN texto_input; 
    END IF;
END;
$function$
