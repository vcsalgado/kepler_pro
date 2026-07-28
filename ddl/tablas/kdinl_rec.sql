CREATE  TABLE keplersc.kdinl_rec (
  fecha_rec timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c18 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdinl_rec ON keplersc.kdinl_rec USING btree (fecha_rec, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinl_rec02 ON keplersc.kdinl_rec USING btree (c1, c12, c11, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinl_rec03 ON keplersc.kdinl_rec USING btree (c1, c11, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinl_rec IS 'Punto recuperacion de resumen de movimientos en inventario';
COMMENT ON COLUMN keplersc.kdinl_rec.fecha_rec IS 'Fecha recuperacion';
COMMENT ON COLUMN keplersc.kdinl_rec.c9 IS 'Total Salidas Monto';
COMMENT ON COLUMN keplersc.kdinl_rec.c8 IS 'Total Entrada Monto';
COMMENT ON COLUMN keplersc.kdinl_rec.c6 IS 'Total Salidas Cantidad';
COMMENT ON COLUMN keplersc.kdinl_rec.c5 IS 'Total Entradas Cantidad';
COMMENT ON COLUMN keplersc.kdinl_rec.c20 IS 'Punto Minimo para Reorden';
COMMENT ON COLUMN keplersc.kdinl_rec.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kdinl_rec.c18 IS 'Penultima Compra';
COMMENT ON COLUMN keplersc.kdinl_rec.c17 IS 'Penunltima Venta';
COMMENT ON COLUMN keplersc.kdinl_rec.c15 IS 'Penultimo costo';
COMMENT ON COLUMN keplersc.kdinl_rec.c14 IS 'Ultimo Costo';
COMMENT ON COLUMN keplersc.kdinl_rec.c12 IS 'Ultima Compra';
COMMENT ON COLUMN keplersc.kdinl_rec.c11 IS 'Ultima Venta';
COMMENT ON COLUMN keplersc.kdinl_rec.c1 IS 'Sucursal';

