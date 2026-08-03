CREATE  TABLE keplersc.kdhoras (
  c1 character varying(7) NOT NULL,
  c2 character varying(1) NOT NULL,
  c3 character varying(10) NOT NULL,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NULL,
  c7 character varying(70) NULL,
  c8 numeric(10,6) NULL,
  c9 character varying(6) NULL,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 character varying(5) NULL,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(5) NULL,
  c14 numeric(20,6) NOT NULL DEFAULT 0,
  c15 numeric(5,2) NOT NULL DEFAULT 0,
  c16 character varying(1) NULL,
  c17 numeric(20,6) NOT NULL DEFAULT 0,
  c18 numeric(20,6) NOT NULL DEFAULT 0,
  c19 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdhoras_c1_idx ON keplersc.kdhoras USING btree (c1, c9, c12, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdhoras_idx ON keplersc.kdhoras USING btree (c1, c2, c3, c4, c5) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdhoras.c9 IS 'Mecanico';
COMMENT ON COLUMN keplersc.kdhoras.c8 IS 'Horas';
COMMENT ON COLUMN keplersc.kdhoras.c7 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdhoras.c6 IS 'Clave';
COMMENT ON COLUMN keplersc.kdhoras.c5 IS 'Partida';
COMMENT ON COLUMN keplersc.kdhoras.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdhoras.c3 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdhoras.c2 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdhoras.c19 IS 'Total cliente';
COMMENT ON COLUMN keplersc.kdhoras.c18 IS 'Monto Iva cliente';
COMMENT ON COLUMN keplersc.kdhoras.c17 IS 'Subtotal Horas';
COMMENT ON COLUMN keplersc.kdhoras.c16 IS 'Abierto o Cerrado';
COMMENT ON COLUMN keplersc.kdhoras.c15 IS 'Factor de Conv';
COMMENT ON COLUMN keplersc.kdhoras.c14 IS 'Costo por Hora';
COMMENT ON COLUMN keplersc.kdhoras.c13 IS 'Hora Fin';
COMMENT ON COLUMN keplersc.kdhoras.c12 IS 'Fecha Fin';
COMMENT ON COLUMN keplersc.kdhoras.c11 IS 'Hora Inicio';
COMMENT ON COLUMN keplersc.kdhoras.c10 IS 'Fecha Inicio';
COMMENT ON COLUMN keplersc.kdhoras.c1 IS 'Sucursal';

