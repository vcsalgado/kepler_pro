CREATE  TABLE keplersc.kdbol (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 numeric(10,2) NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdbol ADD CONSTRAINT pk_kdbol PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdbol IS 'Pedido sugerido resumen movimientos';
COMMENT ON COLUMN keplersc.kdbol.c4 IS 'Total salidas';
COMMENT ON COLUMN keplersc.kdbol.c3 IS 'Total entradas';
COMMENT ON COLUMN keplersc.kdbol.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdbol.c1 IS 'Clave sucursal';

