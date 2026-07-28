CREATE  TABLE keplersc.kdinl_bk (
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
CREATE UNIQUE INDEX IF NOT EXISTS kdinl_bk_c1_c2_idx ON keplersc.kdinl_bk USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdinl_bk_c1_c12_c11_c2_idx ON keplersc.kdinl_bk USING btree (c1, c12, c11, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdinl_bk_c1_c11_c2_idx ON keplersc.kdinl_bk USING btree (c1, c11, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdinl_bk.c9 IS 'Total Salidas Monto';
COMMENT ON COLUMN keplersc.kdinl_bk.c8 IS 'Total Entrada Monto';
COMMENT ON COLUMN keplersc.kdinl_bk.c6 IS 'Total Salidas Cantidad';
COMMENT ON COLUMN keplersc.kdinl_bk.c5 IS 'Total Entradas Cantidad';
COMMENT ON COLUMN keplersc.kdinl_bk.c20 IS 'Punto Minimo para Reorden';
COMMENT ON COLUMN keplersc.kdinl_bk.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kdinl_bk.c18 IS 'Penultima Compra';
COMMENT ON COLUMN keplersc.kdinl_bk.c17 IS 'Penunltima Venta';
COMMENT ON COLUMN keplersc.kdinl_bk.c15 IS 'Penultimo costo';
COMMENT ON COLUMN keplersc.kdinl_bk.c14 IS 'Ultimo Costo';
COMMENT ON COLUMN keplersc.kdinl_bk.c12 IS 'Ultima Compra';
COMMENT ON COLUMN keplersc.kdinl_bk.c11 IS 'Ultima Venta';
COMMENT ON COLUMN keplersc.kdinl_bk.c1 IS 'Sucursal';

