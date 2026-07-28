CREATE  TABLE keplersc.kdtvr2 (
  c1 character varying(15) NOT NULL DEFAULT ''::character varying,
  c2 character varying(15) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric(8,2) NOT NULL DEFAULT 0,
  c11 character varying(2) NOT NULL DEFAULT ''::character varying,
  c12 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtvr2 ADD CONSTRAINT kdtvr2_pk PRIMARY KEY (c1);
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdtvr2 ON keplersc.kdtvr2 USING btree (c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtvr2.c9 IS 'Cantidad por Unidad';
COMMENT ON COLUMN keplersc.kdtvr2.c8 IS 'Precio Publico';
COMMENT ON COLUMN keplersc.kdtvr2.c7 IS 'Precio Mayoreo';
COMMENT ON COLUMN keplersc.kdtvr2.c6 IS 'Costo Distribuidor';
COMMENT ON COLUMN keplersc.kdtvr2.c5 IS 'Codigo de Accesorio';
COMMENT ON COLUMN keplersc.kdtvr2.c4 IS 'Clasificacion por Movimiento';
COMMENT ON COLUMN keplersc.kdtvr2.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtvr2.c2 IS 'En Blanco';
COMMENT ON COLUMN keplersc.kdtvr2.c12 IS 'No usado';
COMMENT ON COLUMN keplersc.kdtvr2.c11 IS 'Parte a cambkok de precios por volumen';
COMMENT ON COLUMN keplersc.kdtvr2.c10 IS 'Cargo por pieza Remanufacturada';
COMMENT ON COLUMN keplersc.kdtvr2.c1 IS 'Part Number';

