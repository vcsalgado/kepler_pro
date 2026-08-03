CREATE  TABLE keplersc.kdsercotdet (
  c1 character varying(7) NULL,
  c2 character varying(10) NULL,
  c3 numeric NULL,
  c4 character varying(50) NULL
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdsercotdet_c1_idx ON keplersc.kdsercotdet USING btree (c1, c2, c3) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdsercotdet.c4 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdsercotdet.c3 IS 'Punto';
COMMENT ON COLUMN keplersc.kdsercotdet.c2 IS 'Cotizacion';
COMMENT ON COLUMN keplersc.kdsercotdet.c1 IS 'Sucursal';

