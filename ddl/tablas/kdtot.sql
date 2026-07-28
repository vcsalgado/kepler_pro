CREATE  TABLE keplersc.kdtot (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 character varying(70) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,10) NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric(20,6) NOT NULL DEFAULT 0,
  c17 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c18 numeric(20,6) NOT NULL DEFAULT 0,
  c19 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtot ADD CONSTRAINT pk_kdtot PRIMARY KEY (c1, c5, c6, c7, c8, c9, c15);
CREATE INDEX IF NOT EXISTS kdtot_c1_idx ON keplersc.kdtot USING btree (c1, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtot02 ON keplersc.kdtot USING btree (c1, c2, c3, c4, c5, c6, c7, c8, c9, c15) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtot03 ON keplersc.kdtot USING btree (c1, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtot04 ON keplersc.kdtot USING btree (c1, c17, c5, c6, c7, c8, c9, c15) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtot IS 'Trabajos otros talleres';
COMMENT ON COLUMN keplersc.kdtot.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdtot.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdtot.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdtot.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdtot.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdtot.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdtot.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdtot.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdtot.c19 IS 'Total cliente';
COMMENT ON COLUMN keplersc.kdtot.c18 IS 'Monto Iva cliente';
COMMENT ON COLUMN keplersc.kdtot.c17 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdtot.c16 IS 'Precio al cliente';
COMMENT ON COLUMN keplersc.kdtot.c15 IS 'Partida';
COMMENT ON COLUMN keplersc.kdtot.c14 IS 'Margen de utilidad';
COMMENT ON COLUMN keplersc.kdtot.c13 IS 'Total';
COMMENT ON COLUMN keplersc.kdtot.c12 IS 'IVA';
COMMENT ON COLUMN keplersc.kdtot.c11 IS 'Subtotal';
COMMENT ON COLUMN keplersc.kdtot.c10 IS 'Descripcion del TOT';
COMMENT ON COLUMN keplersc.kdtot.c1 IS 'Sucursal';

