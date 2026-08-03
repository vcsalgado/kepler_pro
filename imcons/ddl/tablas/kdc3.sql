CREATE  TABLE keplersc.kdc3 (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdc3 ON keplersc.kdc3 USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdc302 ON keplersc.kdc3 USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdc3 IS 'Departamentos';
COMMENT ON COLUMN keplersc.kdc3.c2 IS 'Nombre del departamento';
COMMENT ON COLUMN keplersc.kdc3.c1 IS 'Clave del departamento';

