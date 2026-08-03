CREATE  TABLE keplersc.kddatimpr (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying,
  c5 character varying(30) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kddatimpr ADD CONSTRAINT pk_kddatimpr PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kddatimpr IS 'Datos impresion cliente';
COMMENT ON COLUMN keplersc.kddatimpr.c6 IS 'RFC';
COMMENT ON COLUMN keplersc.kddatimpr.c5 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kddatimpr.c4 IS 'Colonia';
COMMENT ON COLUMN keplersc.kddatimpr.c3 IS 'Direccion';
COMMENT ON COLUMN keplersc.kddatimpr.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kddatimpr.c1 IS 'Clave cliente';

