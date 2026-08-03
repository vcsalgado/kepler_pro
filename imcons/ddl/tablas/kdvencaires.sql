CREATE  TABLE keplersc.kdvencaires (
  c1 character varying(7) NULL,
  c2 character varying(18) NULL,
  c3 character varying(4) NULL,
  c4 character varying(2) NULL,
  c5 numeric(10,2) NULL
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvencaires.c5 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdvencaires.c4 IS 'Mes';
COMMENT ON COLUMN keplersc.kdvencaires.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdvencaires.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdvencaires.c1 IS 'Sucursal';

