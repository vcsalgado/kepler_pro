CREATE  TABLE keplersc.kdic (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdic ADD CONSTRAINT pk_kdic PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdic02 ON keplersc.kdic USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdic.c2 IS 'Descripcion linea';
COMMENT ON COLUMN keplersc.kdic.c1 IS 'Clave linea';

