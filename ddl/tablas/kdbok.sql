CREATE  TABLE keplersc.kdbok (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdbok ADD CONSTRAINT pk_kdbok PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON TABLE keplersc.kdbok IS 'Backorder resumen movimientos';
COMMENT ON COLUMN keplersc.kdbok.c6 IS 'Salidas';
COMMENT ON COLUMN keplersc.kdbok.c5 IS 'Entradas';
COMMENT ON COLUMN keplersc.kdbok.c4 IS 'Mes';
COMMENT ON COLUMN keplersc.kdbok.c3 IS 'Año';
COMMENT ON COLUMN keplersc.kdbok.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdbok.c1 IS 'Clave sucursal';

