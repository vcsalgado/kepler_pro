CREATE  TABLE keplersc.kdginv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(18) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdginv ADD CONSTRAINT pk_kdginv PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdginv02 ON keplersc.kdginv USING btree (c1, c7, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdginv03 ON keplersc.kdginv USING btree (c1, c7, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdginv04 ON keplersc.kdginv USING btree (c1, c7, c2, c4, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdginv IS 'Entradas y salidas al costo';
COMMENT ON COLUMN keplersc.kdginv.c9 IS 'Color interior';
COMMENT ON COLUMN keplersc.kdginv.c8 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdginv.c7 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdginv.c6 IS 'Salidas';
COMMENT ON COLUMN keplersc.kdginv.c5 IS 'Entradas';
COMMENT ON COLUMN keplersc.kdginv.c4 IS 'Anio';
COMMENT ON COLUMN keplersc.kdginv.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdginv.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdginv.c14 IS 'Salidas de IVA';
COMMENT ON COLUMN keplersc.kdginv.c13 IS 'Entradas de IVA';
COMMENT ON COLUMN keplersc.kdginv.c12 IS 'Salidas de Costo';
COMMENT ON COLUMN keplersc.kdginv.c11 IS 'Entradas de Costo';
COMMENT ON COLUMN keplersc.kdginv.c10 IS 'Nuevo / Usado';
COMMENT ON COLUMN keplersc.kdginv.c1 IS 'Sucursal';

