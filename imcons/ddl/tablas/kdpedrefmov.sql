CREATE  TABLE keplersc.kdpedrefmov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0,
  c12 numeric(10,2) NOT NULL DEFAULT 0,
  c13 numeric(10,2) NOT NULL DEFAULT 0,
  c14 numeric(10,2) NOT NULL DEFAULT 0,
  c15 numeric(10,2) NOT NULL DEFAULT 0,
  c16 numeric(10,2) NOT NULL DEFAULT 0,
  c17 numeric(10,2) NOT NULL DEFAULT 0,
  c18 numeric(10,2) NOT NULL DEFAULT 0,
  c19 numeric(10,2) NOT NULL DEFAULT 0,
  c20 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedrefmov ADD CONSTRAINT pk_kdpedrefmov PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdpedrefmov02 ON keplersc.kdpedrefmov USING btree (c1, c4, c5, c6, c7, c8, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedrefmov03 ON keplersc.kdpedrefmov USING btree (c10, c1, c3, c9, c4, c5, c6, c7, c8) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdpedrefmov.c9 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdpedrefmov.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdpedrefmov.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdpedrefmov.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdpedrefmov.c5 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdpedrefmov.c4 IS 'Genero';
COMMENT ON COLUMN keplersc.kdpedrefmov.c3 IS 'Producto';
COMMENT ON COLUMN keplersc.kdpedrefmov.c20 IS 'Cantidad citas';
COMMENT ON COLUMN keplersc.kdpedrefmov.c2 IS 'Referencia';
COMMENT ON COLUMN keplersc.kdpedrefmov.c19 IS 'Cantidad surtida';
COMMENT ON COLUMN keplersc.kdpedrefmov.c18 IS 'Cantidad solicitada';
COMMENT ON COLUMN keplersc.kdpedrefmov.c17 IS 'Cantidad solicitada stock';
COMMENT ON COLUMN keplersc.kdpedrefmov.c16 IS 'Bacl Order';
COMMENT ON COLUMN keplersc.kdpedrefmov.c15 IS 'Existencia';
COMMENT ON COLUMN keplersc.kdpedrefmov.c14 IS 'MIP';
COMMENT ON COLUMN keplersc.kdpedrefmov.c13 IS 'Factor conversion';
COMMENT ON COLUMN keplersc.kdpedrefmov.c12 IS 'Cantidad sugerida stock';
COMMENT ON COLUMN keplersc.kdpedrefmov.c11 IS 'Cantidad especial';
COMMENT ON COLUMN keplersc.kdpedrefmov.c10 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdpedrefmov.c1 IS 'Sucursal';

