CREATE  TABLE keplersc.kdtvr2_030125 (
  c1 character varying(15) NOT NULL,
  c2 character varying(15) NULL,
  c3 character varying(20) NULL,
  c4 character varying(2) NULL,
  c5 character varying(1) NULL,
  c6 numeric(15,2) NULL,
  c7 numeric(15,2) NULL,
  c8 numeric(15,2) NULL,
  c9 numeric NULL,
  c10 numeric(8,2) NULL,
  c11 character varying(2) NULL,
  c12 character varying(5) NULL
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtvr2_030125.c9 IS 'Cantidad por Unidad';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c8 IS 'Precio Publico';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c7 IS 'Precio Mayoreo';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c6 IS 'Costo Distribuidor';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c5 IS 'Codigo de Accesorio';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c4 IS 'Clasificacion por Movimiento';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c2 IS 'En Blanco';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c12 IS 'No usado';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c11 IS 'Parte a cambkok de precios por volumen';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c10 IS 'Cargo por pieza Remanufacturada';
COMMENT ON COLUMN keplersc.kdtvr2_030125.c1 IS 'Part Number';

