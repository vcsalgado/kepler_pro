CREATE  TABLE keplersc.kdxk (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxk02 ON keplersc.kdxk USING btree (c2, c1) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdxk ON keplersc.kdxk USING btree (c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdxk IS 'Zonas';
COMMENT ON COLUMN keplersc.kdxk.c2 IS 'Descripcion zonas';
COMMENT ON COLUMN keplersc.kdxk.c1 IS 'Clave zona';

