CREATE  TABLE keplersc.kdcar (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(70) NOT NULL DEFAULT ''::character varying,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,10) NOT NULL DEFAULT 0,
  c10 numeric(20,6) NOT NULL DEFAULT 0,
  c11 numeric(20,6) NOT NULL DEFAULT 0,
  c12 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcar ADD CONSTRAINT pk_kdcar PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdcar IS 'cargos varios por cada punto de servicio';
COMMENT ON COLUMN keplersc.kdcar.c9 IS 'Margen';
COMMENT ON COLUMN keplersc.kdcar.c8 IS 'Costo sin IVA';
COMMENT ON COLUMN keplersc.kdcar.c7 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcar.c6 IS 'Clave';
COMMENT ON COLUMN keplersc.kdcar.c5 IS 'Partida';
COMMENT ON COLUMN keplersc.kdcar.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdcar.c3 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdcar.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdcar.c12 IS 'Total cliente';
COMMENT ON COLUMN keplersc.kdcar.c11 IS 'Monto Iva cliente';
COMMENT ON COLUMN keplersc.kdcar.c10 IS 'Precio';
COMMENT ON COLUMN keplersc.kdcar.c1 IS 'Sucursal';

