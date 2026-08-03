CREATE  TABLE keplersc.migracion_tablascampos75 (
  tabla character varying(30) NOT NULL,
  campo character varying(3) NOT NULL,
  tipo character varying(20) NULL,
  descripcion character varying(200) NULL,
  longitudreal integer NULL,
  pos_ini integer NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS "TablasCampos75_pkey" ON keplersc.migracion_tablascampos75 USING btree (tabla, campo) TABLESPACE pg_default;

