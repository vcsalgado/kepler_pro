CREATE  TABLE keplersc.kdcm (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric(15,2) NOT NULL DEFAULT 0,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 character varying(40) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 character varying(15) NOT NULL DEFAULT ''::character varying,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
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
  c31 numeric(15,2) NOT NULL DEFAULT 0,
  c32 numeric(15,2) NOT NULL DEFAULT 0,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 numeric(15,2) NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 numeric(15,2) NOT NULL DEFAULT 0,
  c37 numeric(15,2) NOT NULL DEFAULT 0,
  c38 numeric(15,2) NOT NULL DEFAULT 0,
  c39 numeric(15,2) NOT NULL DEFAULT 0,
  c40 numeric(15,2) NOT NULL DEFAULT 0,
  c41 numeric(15,2) NOT NULL DEFAULT 0,
  c42 numeric(15,2) NOT NULL DEFAULT 0,
  c43 numeric(15,2) NOT NULL DEFAULT 0,
  c44 numeric(15,2) NOT NULL DEFAULT 0,
  c45 numeric(15,2) NOT NULL DEFAULT 0,
  c46 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcm ADD CONSTRAINT pk_kdcm PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdcm02 ON keplersc.kdcm USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcm IS 'Presupuestos orden trabajo';
COMMENT ON COLUMN keplersc.kdcm.c6 IS 'Descripcion concepto';
COMMENT ON COLUMN keplersc.kdcm.c5 IS 'Monto del real';
COMMENT ON COLUMN keplersc.kdcm.c4 IS 'Asignacion temporal';
COMMENT ON COLUMN keplersc.kdcm.c3 IS 'Monto presupuesto';
COMMENT ON COLUMN keplersc.kdcm.c2 IS 'Clave orden de trabajo';
COMMENT ON COLUMN keplersc.kdcm.c1 IS 'Clave departamento';

