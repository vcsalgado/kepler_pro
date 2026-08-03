CREATE  TABLE keplersc.kdrefdir (
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
  c11 character varying(20) NOT NULL DEFAULT ''::character varying,
  c12 character varying(30) NOT NULL DEFAULT ''::character varying,
  c13 numeric(6,2) NOT NULL DEFAULT 0,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,10) NOT NULL DEFAULT 0,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c21 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdrefdir ADD CONSTRAINT pk_kdrefdir PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10);
CREATE INDEX IF NOT EXISTS sindkdrefdir02 ON keplersc.kdrefdir USING btree (c1, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdrefdir03 ON keplersc.kdrefdir USING btree (c1, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdrefdir04 ON keplersc.kdrefdir USING btree (c1, c11, c20, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdrefdir.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdrefdir.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdrefdir.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdrefdir.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdrefdir.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdrefdir.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdrefdir.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdrefdir.c21 IS 'Clave del Producto';
COMMENT ON COLUMN keplersc.kdrefdir.c20 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdrefdir.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdrefdir.c19 IS 'Costo de la Partida';
COMMENT ON COLUMN keplersc.kdrefdir.c18 IS 'Interna o Externa';
COMMENT ON COLUMN keplersc.kdrefdir.c17 IS 'Margen de utilidad';
COMMENT ON COLUMN keplersc.kdrefdir.c16 IS 'Importe';
COMMENT ON COLUMN keplersc.kdrefdir.c15 IS 'Unitario';
COMMENT ON COLUMN keplersc.kdrefdir.c14 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdrefdir.c13 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdrefdir.c12 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdrefdir.c11 IS 'Clave';
COMMENT ON COLUMN keplersc.kdrefdir.c10 IS 'Partida';
COMMENT ON COLUMN keplersc.kdrefdir.c1 IS 'Sucursal';

