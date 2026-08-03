CREATE  TABLE keplersc.kdtemp700 (
  c1 character varying NOT NULL,
  c2 character varying NULL,
  c3 numeric(15,2) NULL,
  c4 numeric(15,2) NULL,
  c5 numeric(15,2) NULL,
  c6 numeric(15,2) NULL,
  c7 numeric(15,2) NULL,
  c8 numeric(15,2) NULL,
  c9 numeric(15,2) NULL,
  c10 numeric(15,2) NULL,
  c11 numeric(15,2) NULL,
  c12 numeric(15,2) NULL,
  c13 numeric(15,2) NULL,
  c14 numeric(15,2) NULL,
  c15 numeric(15,2) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtemp700 ADD CONSTRAINT kdtemp700_pk PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdtemp700.c9 IS 'Junio';
COMMENT ON COLUMN keplersc.kdtemp700.c8 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdtemp700.c7 IS 'Abril';
COMMENT ON COLUMN keplersc.kdtemp700.c6 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdtemp700.c5 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdtemp700.c4 IS 'Enero';
COMMENT ON COLUMN keplersc.kdtemp700.c3 IS 'Inicial';
COMMENT ON COLUMN keplersc.kdtemp700.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtemp700.c15 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdtemp700.c14 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdtemp700.c13 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdtemp700.c12 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdtemp700.c11 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdtemp700.c10 IS 'Julio';
COMMENT ON COLUMN keplersc.kdtemp700.c1 IS 'Subcuenta';

