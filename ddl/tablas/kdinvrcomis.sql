CREATE  TABLE keplersc.kdinvrcomis (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinvrcomis ADD CONSTRAINT pk_kdinvrcomis PRIMARY KEY (c1, c2, c3, c4, c5);
CREATE INDEX IF NOT EXISTS sindkdinvrcomis02 ON keplersc.kdinvrcomis USING btree (c1, c11, c6, c2, c3, c4, c5) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdinvrcomis.c9 IS 'Costo';
COMMENT ON COLUMN keplersc.kdinvrcomis.c8 IS 'IVA';
COMMENT ON COLUMN keplersc.kdinvrcomis.c7 IS 'Importe';
COMMENT ON COLUMN keplersc.kdinvrcomis.c6 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdinvrcomis.c5 IS 'Folio';
COMMENT ON COLUMN keplersc.kdinvrcomis.c4 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdinvrcomis.c3 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdinvrcomis.c2 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdinvrcomis.c11 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdinvrcomis.c10 IS 'Dias ultima compra';
COMMENT ON COLUMN keplersc.kdinvrcomis.c1 IS 'Sucursal';

