CREATE  TABLE keplersc.kdsercotref (
  c1 character varying(7) NULL,
  c2 character varying(10) NULL,
  c3 numeric NULL,
  c4 character varying(20) NULL,
  c5 character varying(60) NULL,
  c6 numeric(6,3) NULL,
  c7 numeric(10,2) NULL,
  c8 numeric(10,2) NULL,
  c9 character varying(5) NULL,
  c10 character varying(5) NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(8) NULL DEFAULT ''::character varying,
  c14 character varying(5) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdsercotref_c1_idx ON keplersc.kdsercotref USING btree (c1, c2, c3, c4) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdsercotref.c9 IS 'Tipo de Parte';
COMMENT ON COLUMN keplersc.kdsercotref.c8 IS 'Importe';
COMMENT ON COLUMN keplersc.kdsercotref.c7 IS 'Precio';
COMMENT ON COLUMN keplersc.kdsercotref.c6 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdsercotref.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdsercotref.c4 IS 'Clave';
COMMENT ON COLUMN keplersc.kdsercotref.c3 IS 'Punto';
COMMENT ON COLUMN keplersc.kdsercotref.c2 IS 'Cotizacion';
COMMENT ON COLUMN keplersc.kdsercotref.c14 IS 'Stock';
COMMENT ON COLUMN keplersc.kdsercotref.c13 IS 'Hora';
COMMENT ON COLUMN keplersc.kdsercotref.c12 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdsercotref.c11 IS '0 sin Estatus 10 Autorizado 20 cancelado';
COMMENT ON COLUMN keplersc.kdsercotref.c10 IS 'Razon de Fracaso';
COMMENT ON COLUMN keplersc.kdsercotref.c1 IS 'Sucursal';

