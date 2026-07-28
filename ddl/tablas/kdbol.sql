CREATE  TABLE keplersc.kdbol (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 numeric(10,2) NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdbol ON keplersc.kdbol USING btree (c1, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdbol IS 'Pedido sugerido resumen movimientos';
COMMENT ON COLUMN keplersc.kdbol.c4 IS 'TotalSalidas';
COMMENT ON COLUMN keplersc.kdbol.c3 IS 'TotalEntradas';
COMMENT ON COLUMN keplersc.kdbol.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdbol.c1 IS 'Sucursal';

