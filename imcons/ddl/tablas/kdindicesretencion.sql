CREATE  TABLE keplersc.kdindicesretencion (
  c1 character varying(4) NOT NULL DEFAULT ''::character varying,
  c2 numeric(15,6) NOT NULL DEFAULT 0,
  c3 numeric(15,6) NOT NULL DEFAULT 0,
  c4 numeric(15,6) NOT NULL DEFAULT 0,
  c5 numeric(15,6) NOT NULL DEFAULT 0,
  c6 numeric(15,6) NOT NULL DEFAULT 0,
  c7 numeric(15,6) NOT NULL DEFAULT 0,
  c8 numeric(15,6) NOT NULL DEFAULT 0,
  c9 numeric(15,6) NOT NULL DEFAULT 0,
  c10 numeric(15,6) NOT NULL DEFAULT 0,
  c11 numeric(15,6) NOT NULL DEFAULT 0,
  c12 numeric(15,6) NOT NULL DEFAULT 0,
  c13 numeric(15,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdindicesretencion ADD CONSTRAINT pk_kdindicesretencion PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdindicesretencion IS 'Indices mensuales de retencion';
COMMENT ON COLUMN keplersc.kdindicesretencion.c9 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdindicesretencion.c8 IS 'Julio';
COMMENT ON COLUMN keplersc.kdindicesretencion.c7 IS 'Junio';
COMMENT ON COLUMN keplersc.kdindicesretencion.c6 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdindicesretencion.c5 IS 'Abril';
COMMENT ON COLUMN keplersc.kdindicesretencion.c4 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdindicesretencion.c3 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdindicesretencion.c2 IS 'Enero';
COMMENT ON COLUMN keplersc.kdindicesretencion.c13 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdindicesretencion.c12 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdindicesretencion.c11 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdindicesretencion.c10 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdindicesretencion.c1 IS 'Anio modelo';

