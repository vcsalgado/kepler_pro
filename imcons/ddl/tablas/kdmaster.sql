CREATE  TABLE keplersc.kdmaster (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 numeric(15,2) NOT NULL DEFAULT 0,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(8) NOT NULL DEFAULT ''::character varying,
  c9 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmaster ADD CONSTRAINT pk_kdmaster PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdmaster02 ON keplersc.kdmaster USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdmaster.c9 IS 'CveAct';
COMMENT ON COLUMN keplersc.kdmaster.c8 IS 'FecAct';
COMMENT ON COLUMN keplersc.kdmaster.c7 IS 'CodOri';
COMMENT ON COLUMN keplersc.kdmaster.c6 IS 'CveDes';
COMMENT ON COLUMN keplersc.kdmaster.c5 IS 'Precio Garantía';
COMMENT ON COLUMN keplersc.kdmaster.c4 IS 'Precio Concesionario';
COMMENT ON COLUMN keplersc.kdmaster.c3 IS 'Precio Publico';
COMMENT ON COLUMN keplersc.kdmaster.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdmaster.c1 IS 'NumPar';

