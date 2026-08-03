CREATE  TABLE keplersc.kdcn19 (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(4) NOT NULL DEFAULT ''::character varying,
  c5 character varying(40) NOT NULL DEFAULT ''::character varying,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcn19 ADD CONSTRAINT pk_kdcn19 PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdcn1902 ON keplersc.kdcn19 USING btree (c2, c1, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcn1903 ON keplersc.kdcn19 USING btree (c3, c1, c2, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcn1904 ON keplersc.kdcn19 USING btree (c4, c2, c1, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcn1905 ON keplersc.kdcn19 USING btree (c4, c3, c1, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcn19 IS 'Proyectos presupuestos';
COMMENT ON COLUMN keplersc.kdcn19.c8 IS 'Asignacion temporal';
COMMENT ON COLUMN keplersc.kdcn19.c7 IS 'Monto real';
COMMENT ON COLUMN keplersc.kdcn19.c6 IS 'Monto presupuesto';
COMMENT ON COLUMN keplersc.kdcn19.c5 IS 'Descripcion concepto';
COMMENT ON COLUMN keplersc.kdcn19.c4 IS 'Anio y mes';
COMMENT ON COLUMN keplersc.kdcn19.c3 IS 'Clave proyecto';
COMMENT ON COLUMN keplersc.kdcn19.c2 IS 'Clave departamento';
COMMENT ON COLUMN keplersc.kdcn19.c1 IS 'Clave concepto';

