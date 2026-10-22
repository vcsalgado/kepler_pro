CREATE OR REPLACE FUNCTION keplersc.unaccent(text)
 RETURNS text
 LANGUAGE c
 STABLE PARALLEL SAFE STRICT
AS '$libdir/unaccent', $function$unaccent_dict$function$
