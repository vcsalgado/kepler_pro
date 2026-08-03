CREATE  TABLE keplersc.kdkcaja (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(4) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 numeric(15,2) NOT NULL DEFAULT 0,
  c32 numeric(15,2) NOT NULL DEFAULT 0,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 numeric(15,2) NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdkcaja ON keplersc.kdkcaja USING btree (c1, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdkcaja.c36 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdkcaja.c35 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdkcaja.c34 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdkcaja.c33 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdkcaja.c32 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdkcaja.c31 IS 'Julio';
COMMENT ON COLUMN keplersc.kdkcaja.c30 IS 'Junio';
COMMENT ON COLUMN keplersc.kdkcaja.c29 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdkcaja.c28 IS 'Abril';
COMMENT ON COLUMN keplersc.kdkcaja.c27 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdkcaja.c26 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdkcaja.c25 IS 'Egresos Enero';
COMMENT ON COLUMN keplersc.kdkcaja.c21 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdkcaja.c20 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdkcaja.c2 IS 'Anio';
COMMENT ON COLUMN keplersc.kdkcaja.c19 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdkcaja.c18 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdkcaja.c17 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdkcaja.c16 IS 'Julio';
COMMENT ON COLUMN keplersc.kdkcaja.c15 IS 'Junio';
COMMENT ON COLUMN keplersc.kdkcaja.c14 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdkcaja.c13 IS 'Abril';
COMMENT ON COLUMN keplersc.kdkcaja.c12 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdkcaja.c11 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdkcaja.c10 IS 'Ingresos Enero';
COMMENT ON COLUMN keplersc.kdkcaja.c1 IS 'Sucursal';

