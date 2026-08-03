CREATE  TABLE keplersc.kdivl (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdivl ADD CONSTRAINT pk_kdivl PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdivl02 ON keplersc.kdivl USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdivl.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdivl.c1 IS 'Linea';

