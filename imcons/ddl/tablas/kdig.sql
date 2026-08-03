CREATE  TABLE keplersc.kdig (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdig ADD CONSTRAINT pk_kdig PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdig02 ON keplersc.kdig USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdig IS 'Lineas';
COMMENT ON COLUMN keplersc.kdig.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdig.c1 IS 'Clave linea';

