CREATE  TABLE keplersc.kdconc (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconc ADD CONSTRAINT pk_kdconc PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdconc02 ON keplersc.kdconc USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdconc IS 'Concesionarios';
COMMENT ON COLUMN keplersc.kdconc.c2 IS 'Nombre del concesionario';
COMMENT ON COLUMN keplersc.kdconc.c1 IS 'Clave';

