CREATE  TABLE keplersc.migracion_log (
  procesoid bigint NULL,
  procesonombre character varying(20) NULL,
  referencia character varying(1000) NULL,
  resultado character varying(200) NULL
) TABLESPACE pg_default;

