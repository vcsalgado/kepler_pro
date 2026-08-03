CREATE  TABLE keplersc.kdkgastos (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(4) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(15,2) NOT NULL DEFAULT 0,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdkgastos ADD CONSTRAINT pk_kdkgastos PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdkgastos IS 'Cargos Abonos mensuales para los Gastos';
COMMENT ON COLUMN keplersc.kdkgastos.c9 IS 'Cargos Junio';
COMMENT ON COLUMN keplersc.kdkgastos.c8 IS 'Cargos Mayo';
COMMENT ON COLUMN keplersc.kdkgastos.c7 IS 'Cargos Abril';
COMMENT ON COLUMN keplersc.kdkgastos.c6 IS 'Cargos Marzo';
COMMENT ON COLUMN keplersc.kdkgastos.c5 IS 'Cargos Febero';
COMMENT ON COLUMN keplersc.kdkgastos.c4 IS 'Cargos Enero';
COMMENT ON COLUMN keplersc.kdkgastos.c31 IS 'Abonos Diciembre';
COMMENT ON COLUMN keplersc.kdkgastos.c30 IS 'Abonos Noviembre';
COMMENT ON COLUMN keplersc.kdkgastos.c29 IS 'Abonos Octubre';
COMMENT ON COLUMN keplersc.kdkgastos.c28 IS 'Abonos Septiembre';
COMMENT ON COLUMN keplersc.kdkgastos.c27 IS 'Abonos Agosto';
COMMENT ON COLUMN keplersc.kdkgastos.c26 IS 'Abonos Julio';
COMMENT ON COLUMN keplersc.kdkgastos.c25 IS 'Abonos Junio';
COMMENT ON COLUMN keplersc.kdkgastos.c24 IS 'Abonos Mayo';
COMMENT ON COLUMN keplersc.kdkgastos.c23 IS 'Abonos Abril';
COMMENT ON COLUMN keplersc.kdkgastos.c22 IS 'Abonos Marzo';
COMMENT ON COLUMN keplersc.kdkgastos.c21 IS 'Abonos Febrero';
COMMENT ON COLUMN keplersc.kdkgastos.c20 IS 'Abonos Enero';
COMMENT ON COLUMN keplersc.kdkgastos.c2 IS 'Anio';
COMMENT ON COLUMN keplersc.kdkgastos.c15 IS 'Cargos Diciembre';
COMMENT ON COLUMN keplersc.kdkgastos.c14 IS 'Cargos Noviembre';
COMMENT ON COLUMN keplersc.kdkgastos.c13 IS 'Cargos Octubre';
COMMENT ON COLUMN keplersc.kdkgastos.c12 IS 'Cargos Septiembre';
COMMENT ON COLUMN keplersc.kdkgastos.c11 IS 'Cargos Agosto';
COMMENT ON COLUMN keplersc.kdkgastos.c10 IS 'Cargos Julio';
COMMENT ON COLUMN keplersc.kdkgastos.c1 IS 'Clave';

