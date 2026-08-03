CREATE  TABLE keplersc.kdctascomispaq (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctascomispaq ADD CONSTRAINT pk_kdctascomispaq PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdctascomispaq IS 'Comisiones paquete';
COMMENT ON COLUMN keplersc.kdctascomispaq.c2 IS 'Comision paquete';
COMMENT ON COLUMN keplersc.kdctascomispaq.c1 IS 'Clave del paquete';

