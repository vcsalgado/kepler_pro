CREATE  TABLE keplersc.kdcontopen (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric NOT NULL DEFAULT 0,
  c17 numeric NOT NULL DEFAULT 0,
  c18 numeric NOT NULL DEFAULT 0,
  c19 numeric NOT NULL DEFAULT 0,
  c20 numeric NOT NULL DEFAULT 0,
  c21 numeric NOT NULL DEFAULT 0,
  c22 numeric NOT NULL DEFAULT 0,
  c23 numeric NOT NULL DEFAULT 0,
  c24 numeric NOT NULL DEFAULT 0,
  c25 numeric NOT NULL DEFAULT 0,
  c26 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcontopen ADD CONSTRAINT pk_kdcontopen PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdcontopen.c9 IS 'Dia cierre para Agosto';
COMMENT ON COLUMN keplersc.kdcontopen.c8 IS 'Dia cierre para Julio';
COMMENT ON COLUMN keplersc.kdcontopen.c7 IS 'Dia cierre para Junio';
COMMENT ON COLUMN keplersc.kdcontopen.c6 IS 'Dia cierre para Mayo';
COMMENT ON COLUMN keplersc.kdcontopen.c5 IS 'Dia cierre para Abril';
COMMENT ON COLUMN keplersc.kdcontopen.c4 IS 'Dia cierre para Marzo';
COMMENT ON COLUMN keplersc.kdcontopen.c3 IS 'Dia cierre para Febrero';
COMMENT ON COLUMN keplersc.kdcontopen.c26 IS 'Cierre de Contabilidad Diciembre';
COMMENT ON COLUMN keplersc.kdcontopen.c25 IS 'Cierre de Contabilidad Noviembre';
COMMENT ON COLUMN keplersc.kdcontopen.c24 IS 'Cierre de Contabilidad Octubre';
COMMENT ON COLUMN keplersc.kdcontopen.c23 IS 'Cierre de Contabilidad Septiembre';
COMMENT ON COLUMN keplersc.kdcontopen.c22 IS 'Cierre de Contabilidad Agosto';
COMMENT ON COLUMN keplersc.kdcontopen.c21 IS 'Cierre de Contabilidad Julio';
COMMENT ON COLUMN keplersc.kdcontopen.c20 IS 'Cierre de Contabilidad Junio';
COMMENT ON COLUMN keplersc.kdcontopen.c2 IS 'Dia cierre para Enero';
COMMENT ON COLUMN keplersc.kdcontopen.c19 IS 'Cierre de Contabilidad Mayo';
COMMENT ON COLUMN keplersc.kdcontopen.c18 IS 'Cierre de Contabilidad Abril';
COMMENT ON COLUMN keplersc.kdcontopen.c17 IS 'Cierre de Contabilidad Marzo';
COMMENT ON COLUMN keplersc.kdcontopen.c16 IS 'Cierre de Contabilidad Febrero';
COMMENT ON COLUMN keplersc.kdcontopen.c15 IS 'Cierre de Contabilidad Enero';
COMMENT ON COLUMN keplersc.kdcontopen.c13 IS 'Dia cierre para Diciembre';
COMMENT ON COLUMN keplersc.kdcontopen.c12 IS 'Dia cierre para Noviembre';
COMMENT ON COLUMN keplersc.kdcontopen.c11 IS 'Dia cierre para Octubre';
COMMENT ON COLUMN keplersc.kdcontopen.c10 IS 'Dia cierre para Septiembre';
COMMENT ON COLUMN keplersc.kdcontopen.c1 IS 'Llave';

