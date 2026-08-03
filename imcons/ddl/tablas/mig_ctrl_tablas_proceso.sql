CREATE  TABLE keplersc.mig_ctrl_tablas_proceso (
  nombre_tabla character varying NOT NULL,
  alcance_tabla character varying NOT NULL DEFAULT 'P'::character varying,
  ultima_migracion timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  proceso_id numeric NOT NULL DEFAULT 0,
  registros_origen numeric NOT NULL DEFAULT 0,
  registros_migrados numeric NOT NULL DEFAULT 0,
  error_global character varying NULL DEFAULT ''::character varying,
  seleccionada character varying NOT NULL DEFAULT 'N'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.mig_ctrl_tablas_proceso ADD CONSTRAINT mig_ctrl_tablas_proceso_pk PRIMARY KEY (nombre_tabla);
CREATE UNIQUE INDEX IF NOT EXISTS mig_ctrl_tablas_proceso_nombre_tabla_idx ON keplersc.mig_ctrl_tablas_proceso USING btree (nombre_tabla) TABLESPACE pg_default;

