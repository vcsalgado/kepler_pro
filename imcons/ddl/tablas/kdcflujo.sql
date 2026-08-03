CREATE  TABLE keplersc.kdcflujo (
  c1 character varying(16) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcflujo ADD CONSTRAINT pk_kdcflujo PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcflujo02 ON keplersc.kdcflujo USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcflujo IS 'Cuenta de Flujo';
COMMENT ON COLUMN keplersc.kdcflujo.c3 IS 'Tipo de Cuenta';
COMMENT ON COLUMN keplersc.kdcflujo.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcflujo.c1 IS 'Cuenta de primer nivel';

