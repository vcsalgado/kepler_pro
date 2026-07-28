CREATE  TABLE keplersc.kdlinv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 character varying(18) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(10) NOT NULL DEFAULT ''::character varying,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdlinv ADD CONSTRAINT pk_kdlinv PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdlinv02 ON keplersc.kdlinv USING btree (c1, c13, c12, c7, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdlinv03 ON keplersc.kdlinv USING btree (c1, c13, c12, c14, c15, c7, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdlinv IS 'Estadistica Inventario Autos';
COMMENT ON COLUMN keplersc.kdlinv.c9 IS 'Ultimo IVA';
COMMENT ON COLUMN keplersc.kdlinv.c8 IS 'Ultimo costo';
COMMENT ON COLUMN keplersc.kdlinv.c7 IS 'Primera fecha';
COMMENT ON COLUMN keplersc.kdlinv.c6 IS 'Salidas en monto';
COMMENT ON COLUMN keplersc.kdlinv.c5 IS 'Entradas en  monto';
COMMENT ON COLUMN keplersc.kdlinv.c4 IS 'Salidas en Unidades';
COMMENT ON COLUMN keplersc.kdlinv.c3 IS 'Entradas en unidades';
COMMENT ON COLUMN keplersc.kdlinv.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdlinv.c15 IS 'Color interior';
COMMENT ON COLUMN keplersc.kdlinv.c14 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdlinv.c13 IS 'Status 0=En inventario; 10=Fuera de inventario';
COMMENT ON COLUMN keplersc.kdlinv.c12 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdlinv.c11 IS 'Salidas de IVA';
COMMENT ON COLUMN keplersc.kdlinv.c10 IS 'Entradas de IVA';
COMMENT ON COLUMN keplersc.kdlinv.c1 IS 'Sucursal';

