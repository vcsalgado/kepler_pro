CREATE  TABLE keplersc.kdinr (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdinr ON keplersc.kdinr USING btree (c2, c3, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinr02 ON keplersc.kdinr USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinr03 ON keplersc.kdinr USING btree (c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinr IS 'Reemplazos';
COMMENT ON COLUMN keplersc.kdinr.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdinr.c2 IS 'Codigo que reemplaza';
COMMENT ON COLUMN keplersc.kdinr.c1 IS 'Reemplazo';

