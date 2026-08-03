CREATE  TABLE keplersc.migracion_75to80 (
  tabla_75 character varying(30) NOT NULL,
  campo_75 character varying(4) NOT NULL,
  tabla_80 character varying(30) NOT NULL,
  campo_80 character varying(4) NOT NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS migracion_75to80_pkey ON keplersc.migracion_75to80 USING btree (tabla_75, campo_75, tabla_80, campo_80) TABLESPACE pg_default;

