CREATE  TABLE keplersc.kdbom (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(18) NOT NULL DEFAULT ''::character varying,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 character varying(8) NOT NULL DEFAULT ''::character varying,
  c12 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdbom ADD CONSTRAINT pk_kdbom PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdbom02 ON keplersc.kdbom USING btree (c1, c10, c11, c8, c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdbom IS 'Backorder moviemientos';
COMMENT ON COLUMN keplersc.kdbom.c9 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdbom.c8 IS 'IDProducto';
COMMENT ON COLUMN keplersc.kdbom.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdbom.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdbom.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdbom.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdbom.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdbom.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdbom.c12 IS 'TipoMovimiento 1-Alta,0-Baja';
COMMENT ON COLUMN keplersc.kdbom.c11 IS 'Hora';
COMMENT ON COLUMN keplersc.kdbom.c10 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdbom.c1 IS 'Sucursal';

