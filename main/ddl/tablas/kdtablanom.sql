CREATE  TABLE keplersc.kdtablanom (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(6) NOT NULL DEFAULT ''::character varying,
  c8 numeric(6,2) NOT NULL DEFAULT 0,
  c9 numeric(6,2) NOT NULL DEFAULT 0,
  c10 numeric(6,2) NOT NULL DEFAULT 0,
  c11 numeric(6,2) NOT NULL DEFAULT 0,
  c12 numeric(10,2) NOT NULL DEFAULT 0,
  c13 numeric(10,2) NOT NULL DEFAULT 0,
  c14 numeric(10,2) NOT NULL DEFAULT 0,
  c15 numeric(10,2) NOT NULL DEFAULT 0,
  c16 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c17 character varying NULL,
  c18 timestamp without time zone NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtablanom ADD CONSTRAINT pk_kdtablanom PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdtablanom02 ON keplersc.kdtablanom USING btree (c1, c7, c16, c2, c3, c4, c5, c6) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtablanom IS 'nomina operarios';
COMMENT ON COLUMN keplersc.kdtablanom.c9 IS 'Horas Base';
COMMENT ON COLUMN keplersc.kdtablanom.c8 IS 'Horas Tabuladas';
COMMENT ON COLUMN keplersc.kdtablanom.c7 IS 'Operario';
COMMENT ON COLUMN keplersc.kdtablanom.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdtablanom.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdtablanom.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdtablanom.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdtablanom.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdtablanom.c18 IS 'Fecha de la Baja';
COMMENT ON COLUMN keplersc.kdtablanom.c17 IS 'Estatus(A=Alta, B=Baja)';
COMMENT ON COLUMN keplersc.kdtablanom.c16 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdtablanom.c15 IS 'Total';
COMMENT ON COLUMN keplersc.kdtablanom.c14 IS 'Incentivo Total';
COMMENT ON COLUMN keplersc.kdtablanom.c13 IS 'Comisiones';
COMMENT ON COLUMN keplersc.kdtablanom.c12 IS 'Sueldo Base';
COMMENT ON COLUMN keplersc.kdtablanom.c11 IS 'Incentivo por Hora';
COMMENT ON COLUMN keplersc.kdtablanom.c10 IS 'Costo Por Hora';
COMMENT ON COLUMN keplersc.kdtablanom.c1 IS 'Sucursal';

