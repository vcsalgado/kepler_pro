CREATE  TABLE keplersc.kdcatgastos (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(60) NOT NULL DEFAULT ''::character varying,
  c3 character varying(16) NOT NULL DEFAULT ''::character varying,
  c4 numeric(10,5) NOT NULL DEFAULT 0,
  c5 character varying(16) NOT NULL DEFAULT ''::character varying,
  c6 numeric(10,5) NOT NULL DEFAULT 0,
  c7 character varying(16) NOT NULL DEFAULT ''::character varying,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 character varying(16) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,5) NOT NULL DEFAULT 0,
  c11 character varying(16) NOT NULL DEFAULT ''::character varying,
  c12 numeric(10,5) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(15,2) NOT NULL DEFAULT 0,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 character varying(50) NOT NULL DEFAULT ''::character varying,
  c26 character varying(50) NOT NULL DEFAULT ''::character varying,
  c27 character varying(50) NOT NULL DEFAULT ''::character varying,
  c28 character varying(50) NOT NULL DEFAULT ''::character varying,
  c29 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatgastos ADD CONSTRAINT pk_kdcatgastos PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcatgastos02 ON keplersc.kdcatgastos USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatgastos03 ON keplersc.kdcatgastos USING btree (c3, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatgastos04 ON keplersc.kdcatgastos USING btree (c5, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatgastos05 ON keplersc.kdcatgastos USING btree (c7, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatgastos06 ON keplersc.kdcatgastos USING btree (c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatgastos07 ON keplersc.kdcatgastos USING btree (c11, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatgastos IS 'Catalogo de Gastos';
COMMENT ON COLUMN keplersc.kdcatgastos.c9 IS 'Cuenta Contable';
COMMENT ON COLUMN keplersc.kdcatgastos.c8 IS 'Prorrateo';
COMMENT ON COLUMN keplersc.kdcatgastos.c7 IS 'Cuenta Contable';
COMMENT ON COLUMN keplersc.kdcatgastos.c6 IS 'Prorrateo';
COMMENT ON COLUMN keplersc.kdcatgastos.c5 IS 'Cuenta Contable';
COMMENT ON COLUMN keplersc.kdcatgastos.c4 IS 'Prorrateo';
COMMENT ON COLUMN keplersc.kdcatgastos.c3 IS 'Cuenta Contable';
COMMENT ON COLUMN keplersc.kdcatgastos.c29 IS 'Aplicación 5';
COMMENT ON COLUMN keplersc.kdcatgastos.c28 IS 'Aplicación 4';
COMMENT ON COLUMN keplersc.kdcatgastos.c27 IS 'Aplicación 3';
COMMENT ON COLUMN keplersc.kdcatgastos.c26 IS 'Aplicación 2';
COMMENT ON COLUMN keplersc.kdcatgastos.c25 IS 'Aplicación 1';
COMMENT ON COLUMN keplersc.kdcatgastos.c24 IS 'Presupuesto Diciembre';
COMMENT ON COLUMN keplersc.kdcatgastos.c23 IS 'Presupuesto Noviembre';
COMMENT ON COLUMN keplersc.kdcatgastos.c22 IS 'Presupuesto Octubre';
COMMENT ON COLUMN keplersc.kdcatgastos.c21 IS 'Presupuesto Septiembre';
COMMENT ON COLUMN keplersc.kdcatgastos.c20 IS 'Presupuesto Agosto';
COMMENT ON COLUMN keplersc.kdcatgastos.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdcatgastos.c19 IS 'Presupuesto Julio';
COMMENT ON COLUMN keplersc.kdcatgastos.c18 IS 'Presupuesto Junio';
COMMENT ON COLUMN keplersc.kdcatgastos.c17 IS 'Presupuesto Mayo';
COMMENT ON COLUMN keplersc.kdcatgastos.c16 IS 'Presupuesto Abril';
COMMENT ON COLUMN keplersc.kdcatgastos.c15 IS 'Presupuesto Marzo';
COMMENT ON COLUMN keplersc.kdcatgastos.c14 IS 'Presupuesto Febrero';
COMMENT ON COLUMN keplersc.kdcatgastos.c13 IS 'Presupuesto Enero';
COMMENT ON COLUMN keplersc.kdcatgastos.c12 IS 'Prorrateo';
COMMENT ON COLUMN keplersc.kdcatgastos.c11 IS 'Cuenta Contable';
COMMENT ON COLUMN keplersc.kdcatgastos.c10 IS 'Prorrateo';
COMMENT ON COLUMN keplersc.kdcatgastos.c1 IS 'Clave';

