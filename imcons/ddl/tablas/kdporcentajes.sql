CREATE  TABLE keplersc.kdporcentajes (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 numeric(10,5) NOT NULL DEFAULT 0,
  c10 numeric(10,5) NOT NULL DEFAULT 0,
  c11 numeric(10,5) NOT NULL DEFAULT 0,
  c12 numeric(10,5) NOT NULL DEFAULT 0,
  c13 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdporcentajes ADD CONSTRAINT pk_kdporcentajes PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdporcentajes IS 'Vendedores porcentajes comision';
COMMENT ON COLUMN keplersc.kdporcentajes.c9 IS 'Porcentaje de reduccion por nota descuento';
COMMENT ON COLUMN keplersc.kdporcentajes.c8 IS 'Porcentaje o cuota edad 4';
COMMENT ON COLUMN keplersc.kdporcentajes.c7 IS 'Porcentaje o cuota edad 3';
COMMENT ON COLUMN keplersc.kdporcentajes.c6 IS 'Porcentaje o cuota edad 2';
COMMENT ON COLUMN keplersc.kdporcentajes.c5 IS 'Porcentaje o cuota edad 1';
COMMENT ON COLUMN keplersc.kdporcentajes.c4 IS 'Porcentaje o cuota';
COMMENT ON COLUMN keplersc.kdporcentajes.c3 IS 'Limite superior';
COMMENT ON COLUMN keplersc.kdporcentajes.c2 IS 'Limite inferior';
COMMENT ON COLUMN keplersc.kdporcentajes.c13 IS 'Porcentaje sobre garantia extendida';
COMMENT ON COLUMN keplersc.kdporcentajes.c12 IS 'Porcentaje sobre accesorios';
COMMENT ON COLUMN keplersc.kdporcentajes.c11 IS 'Porcentaje sobre seguro';
COMMENT ON COLUMN keplersc.kdporcentajes.c10 IS 'Porcentaje sobre gastos administrativos';
COMMENT ON COLUMN keplersc.kdporcentajes.c1 IS 'Tipo de comision';

