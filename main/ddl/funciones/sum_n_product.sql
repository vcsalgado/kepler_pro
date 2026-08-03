CREATE OR REPLACE FUNCTION keplersc.sum_n_product(x integer, y integer, OUT sum integer, OUT prod integer)
 RETURNS record
 LANGUAGE plpgsql
AS $function$
BEGIN
    sum := x + y;
    prod := x * y;
END;
$function$
