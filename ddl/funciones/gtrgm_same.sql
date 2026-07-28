CREATE OR REPLACE FUNCTION keplersc.gtrgm_same(keplersc.gtrgm, keplersc.gtrgm, internal)
 RETURNS internal
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_same$function$
