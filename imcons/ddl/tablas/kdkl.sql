CREATE  TABLE keplersc.kdkl (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdkl ON keplersc.kdkl USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdkl02 ON keplersc.kdkl USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdkl.c3 IS 'Prefijo de lenguaje';
COMMENT ON COLUMN keplersc.kdkl.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdkl.c1 IS 'Clave';

