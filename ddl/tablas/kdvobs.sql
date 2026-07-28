CREATE  TABLE keplersc.kdvobs (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 character varying(18) NOT NULL DEFAULT ''::character varying,
  c13 numeric(10,5) NOT NULL DEFAULT 0,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 numeric(10,2) NOT NULL DEFAULT 0,
  c16 numeric(10,2) NOT NULL DEFAULT 0,
  c17 numeric(10,2) NOT NULL DEFAULT 0,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvobs ADD CONSTRAINT pk_kdvobs PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdvobs02 ON keplersc.kdvobs USING btree (c1, c8, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvobs03 ON keplersc.kdvobs USING btree (c1, c11, c8, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvobs04 ON keplersc.kdvobs USING btree (c1, c12, c8, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdvobs IS 'Productos obsoletos';
COMMENT ON COLUMN keplersc.kdvobs.c9 IS 'Fecha ultima venta';
COMMENT ON COLUMN keplersc.kdvobs.c8 IS 'Fecha de Venta';
COMMENT ON COLUMN keplersc.kdvobs.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdvobs.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvobs.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvobs.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvobs.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvobs.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvobs.c17 IS 'Costo';
COMMENT ON COLUMN keplersc.kdvobs.c16 IS 'IVA';
COMMENT ON COLUMN keplersc.kdvobs.c15 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvobs.c14 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdvobs.c13 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdvobs.c12 IS 'Clave';
COMMENT ON COLUMN keplersc.kdvobs.c11 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdvobs.c10 IS 'Fecha ultima compra';
COMMENT ON COLUMN keplersc.kdvobs.c1 IS 'Sucursal';

