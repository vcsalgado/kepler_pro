CREATE  TABLE keplersc.kdtomas (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(20) NOT NULL DEFAULT ''::character varying,
  c5 character varying(50) NOT NULL DEFAULT ''::character varying,
  c6 character varying(4) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(40) NOT NULL DEFAULT ''::character varying,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(20) NOT NULL DEFAULT ''::character varying,
  c12 character varying(30) NULL DEFAULT ''::character varying,
  c13 timestamp without time zone NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c14 character varying(40) NULL DEFAULT ''::character varying,
  c15 character varying(30) NOT NULL DEFAULT ''::character varying,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtomas ADD CONSTRAINT pk_kdtomas PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdtomas IS 'Toma de Vehiculos';
COMMENT ON COLUMN keplersc.kdtomas.c9 IS 'Monto Adquisicion';
COMMENT ON COLUMN keplersc.kdtomas.c8 IS 'NIV';
COMMENT ON COLUMN keplersc.kdtomas.c7 IS 'VIN';
COMMENT ON COLUMN keplersc.kdtomas.c6 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdtomas.c5 IS 'Tipo de Vehiculo';
COMMENT ON COLUMN keplersc.kdtomas.c4 IS 'Clave Vehicular';
COMMENT ON COLUMN keplersc.kdtomas.c3 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdtomas.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdtomas.c17 IS 'Valor';
COMMENT ON COLUMN keplersc.kdtomas.c16 IS 'Marca';
COMMENT ON COLUMN keplersc.kdtomas.c15 IS 'Version';
COMMENT ON COLUMN keplersc.kdtomas.c14 IS 'Aduana';
COMMENT ON COLUMN keplersc.kdtomas.c13 IS 'Fecha de Importacion';
COMMENT ON COLUMN keplersc.kdtomas.c12 IS 'Numero de Importacion';
COMMENT ON COLUMN keplersc.kdtomas.c11 IS 'Numero de motor';
COMMENT ON COLUMN keplersc.kdtomas.c10 IS 'Monto Enajenacion';
COMMENT ON COLUMN keplersc.kdtomas.c1 IS 'Sucursal';

