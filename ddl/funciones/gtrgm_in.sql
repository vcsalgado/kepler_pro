CREATE OR REPLACE FUNCTION keplersc.gtrgm_in(cstring)
 RETURNS keplersc.gtrgm
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_in$function$
