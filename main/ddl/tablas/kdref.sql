CREATE  TABLE keplersc.kdref (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(18) NOT NULL DEFAULT ''::character varying,
  c12 character varying(60) NOT NULL DEFAULT ''::character varying,
  c13 numeric(15,6) NOT NULL DEFAULT 0,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(20,6) NOT NULL DEFAULT 0,
  c17 numeric(15,10) NOT NULL DEFAULT 0,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c21 numeric(20,6) NOT NULL DEFAULT 0,
  c22 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdref ADD CONSTRAINT pk_kdref PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10);
CREATE INDEX IF NOT EXISTS sindkdref02 ON keplersc.kdref USING btree (c1, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdref03 ON keplersc.kdref USING btree (c1, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdref04 ON keplersc.kdref USING btree (c1, c20, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdref IS 'refacciones cargadas por cada punto de servicio';
COMMENT ON COLUMN keplersc.kdref.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdref.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdref.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdref.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdref.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdref.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdref.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdref.c22 IS 'Total cliente';
COMMENT ON COLUMN keplersc.kdref.c21 IS 'Monto Iva cliente';
COMMENT ON COLUMN keplersc.kdref.c20 IS 'Fecha del movimiento';
COMMENT ON COLUMN keplersc.kdref.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdref.c19 IS 'Costo de la partida';
COMMENT ON COLUMN keplersc.kdref.c18 IS 'Interna o Externa';
COMMENT ON COLUMN keplersc.kdref.c17 IS 'Margen de utilidad';
COMMENT ON COLUMN keplersc.kdref.c16 IS 'Importe';
COMMENT ON COLUMN keplersc.kdref.c15 IS 'Unitario';
COMMENT ON COLUMN keplersc.kdref.c14 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdref.c13 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdref.c12 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdref.c11 IS 'Clave';
COMMENT ON COLUMN keplersc.kdref.c10 IS 'Partida';
COMMENT ON COLUMN keplersc.kdref.c1 IS 'Sucursal';

