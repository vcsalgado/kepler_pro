CREATE  TABLE keplersc.kdcajdep (
  c1 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c2 numeric(20,2) NOT NULL DEFAULT 0,
  c3 numeric(20,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdcajdep ON keplersc.kdcajdep USING btree (c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcajdep IS 'Movimientos de caja';
COMMENT ON COLUMN keplersc.kdcajdep.c3 IS 'Egresos';
COMMENT ON COLUMN keplersc.kdcajdep.c2 IS 'Ingresos';
COMMENT ON COLUMN keplersc.kdcajdep.c1 IS 'Fecha Ingreso';

