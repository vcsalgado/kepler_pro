CREATE  TABLE keplersc.kdvcm (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(18) NOT NULL DEFAULT ''::character varying,
  c16 character varying(18) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvcm ADD CONSTRAINT pk_kdvcm PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdvcm02 ON keplersc.kdvcm USING btree (c1, c8, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvcm03 ON keplersc.kdvcm USING btree (c1, c15, c8, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvcm04 ON keplersc.kdvcm USING btree (c1, c15, c2, c8, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdvcm IS 'Detalle de ventas';
COMMENT ON COLUMN keplersc.kdvcm.c9 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdvcm.c8 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvcm.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdvcm.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvcm.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvcm.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvcm.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvcm.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvcm.c16 IS 'Reemplazo';
COMMENT ON COLUMN keplersc.kdvcm.c15 IS 'Producto';
COMMENT ON COLUMN keplersc.kdvcm.c13 IS 'Costo';
COMMENT ON COLUMN keplersc.kdvcm.c12 IS 'IVA';
COMMENT ON COLUMN keplersc.kdvcm.c11 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvcm.c10 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdvcm.c1 IS 'Sucursal';

