CREATE  TABLE keplersc.kdadheader (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdadheader ADD CONSTRAINT pk_kdadheader PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdadheader02 ON keplersc.kdadheader USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdadheader IS 'Adendas header';
COMMENT ON COLUMN keplersc.kdadheader.c3 IS 'Clave cliente';
COMMENT ON COLUMN keplersc.kdadheader.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdadheader.c1 IS 'Clave';

