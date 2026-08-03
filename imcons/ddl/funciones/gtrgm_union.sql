CREATE OR REPLACE FUNCTION keplersc.gtrgm_union(internal, internal)
 RETURNS keplersc.gtrgm
 LANGUAGE c
 IMMUTABLE PARALLEL SAFE STRICT
AS '$libdir/pg_trgm', $function$gtrgm_union$function$
