CREATE  TABLE keplersc.kdinfvus (
  c1 character varying(50) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT '1900'::character varying,
  c4 character varying(100) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 4,
  c9 numeric NOT NULL DEFAULT 4,
  c10 numeric NOT NULL DEFAULT 4,
  c11 character varying(10) NOT NULL DEFAULT 'GASOLINA'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinfvus ADD CONSTRAINT pk_kdinfvus PRIMARY KEY (c5);
COMMENT ON COLUMN keplersc.kdinfvus.c9 IS 'Numero Cilindros';
COMMENT ON COLUMN keplersc.kdinfvus.c8 IS 'Capacidad Ocupantes';
COMMENT ON COLUMN keplersc.kdinfvus.c7 IS 'Procedencia';
COMMENT ON COLUMN keplersc.kdinfvus.c6 IS 'Estatus : 1 Asignado , 0 or Null Por Asignar';
COMMENT ON COLUMN keplersc.kdinfvus.c5 IS 'serie o vin';
COMMENT ON COLUMN keplersc.kdinfvus.c4 IS 'version';
COMMENT ON COLUMN keplersc.kdinfvus.c3 IS 'anio';
COMMENT ON COLUMN keplersc.kdinfvus.c2 IS 'modelo';
COMMENT ON COLUMN keplersc.kdinfvus.c11 IS 'Combustible';
COMMENT ON COLUMN keplersc.kdinfvus.c10 IS 'Numero Puertas';
COMMENT ON COLUMN keplersc.kdinfvus.c1 IS 'marca';

