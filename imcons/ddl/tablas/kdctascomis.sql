CREATE  TABLE keplersc.kdctascomis (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdctascomis.c3 IS 'Comision por cita';
COMMENT ON COLUMN keplersc.kdctascomis.c2 IS 'Limite superior';
COMMENT ON COLUMN keplersc.kdctascomis.c1 IS 'Limite inferior';

