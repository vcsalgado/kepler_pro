CREATE  TABLE keplersc.migracion_tablas75 (
  tabla character varying(30) NOT NULL,
  campos_diag integer NULL,
  descripcion character varying(30) NULL,
  orden_migracion integer NULL,
  max_campo integer NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS tablas75_pkey ON keplersc.migracion_tablas75 USING btree (tabla) TABLESPACE pg_default;

