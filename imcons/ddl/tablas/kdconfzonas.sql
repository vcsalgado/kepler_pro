CREATE  TABLE keplersc.kdconfzonas (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric(8,2) NOT NULL DEFAULT 0,
  c3 numeric(8,2) NOT NULL DEFAULT 0,
  c4 numeric(8,2) NOT NULL DEFAULT 0,
  c5 numeric(8,2) NOT NULL DEFAULT 0,
  c6 numeric(8,2) NOT NULL DEFAULT 0,
  c7 numeric(8,2) NOT NULL DEFAULT 0,
  c8 numeric(8,2) NOT NULL DEFAULT 0,
  c9 numeric(8,2) NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfzonas ADD CONSTRAINT pk_kdconfzonas PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdconfzonas.c4 IS 'Inferior Alto Movimiento';
COMMENT ON COLUMN keplersc.kdconfzonas.c3 IS 'Superior Zona Dorada';
COMMENT ON COLUMN keplersc.kdconfzonas.c2 IS 'Inferior Zona Dorada';
COMMENT ON COLUMN keplersc.kdconfzonas.c1 IS 'ID';

