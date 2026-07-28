CREATE  TABLE keplersc.kdxf (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(7) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxf03 ON keplersc.kdxf USING btree (c1, c4, c5, c6, c3, c7, c8, c9, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxf04 ON keplersc.kdxf USING btree (c1, c7, c8, c9, c3, c4, c5, c6, c2) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdxf ON keplersc.kdxf USING btree (c1, c2, c4, c5, c6, c3, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxf02 ON keplersc.kdxf USING btree (c1, c2, c7, c8, c9, c3, c4, c5, c6) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdxf.c9 IS 'Monto cargo';
COMMENT ON COLUMN keplersc.kdxf.c8 IS 'Numero abono';
COMMENT ON COLUMN keplersc.kdxf.c7 IS 'Tipo abono';
COMMENT ON COLUMN keplersc.kdxf.c6 IS 'Grupo abono';
COMMENT ON COLUMN keplersc.kdxf.c5 IS 'Tipo cargo';
COMMENT ON COLUMN keplersc.kdxf.c4 IS 'Grupo cargo';
COMMENT ON COLUMN keplersc.kdxf.c3 IS 'Movimiento';
COMMENT ON COLUMN keplersc.kdxf.c2 IS 'Proveedor';
COMMENT ON COLUMN keplersc.kdxf.c10 IS 'Monto abono';
COMMENT ON COLUMN keplersc.kdxf.c1 IS 'Sucursal';

