CREATE  TABLE keplersc.kdvck (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(7) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvck ADD CONSTRAINT pk_kdvck PRIMARY KEY (c1, c2, c3, c4, c5, c6);
CREATE INDEX IF NOT EXISTS sindkdvck02 ON keplersc.kdvck USING btree (c1, c7, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvck03 ON keplersc.kdvck USING btree (c1, c7, c12, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvck04 ON keplersc.kdvck USING btree (c1, c7, c13, c2, c3, c4, c5, c6) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvck.c9 IS 'IVA';
COMMENT ON COLUMN keplersc.kdvck.c8 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvck.c7 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvck.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvck.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvck.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvck.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvck.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvck.c13 IS 'Vendedor-Comprador';
COMMENT ON COLUMN keplersc.kdvck.c12 IS 'Cliente-Proveedor';
COMMENT ON COLUMN keplersc.kdvck.c10 IS 'Costo';
COMMENT ON COLUMN keplersc.kdvck.c1 IS 'Sucursal';

