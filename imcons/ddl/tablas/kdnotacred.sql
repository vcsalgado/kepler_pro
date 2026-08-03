CREATE  TABLE keplersc.kdnotacred (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 numeric NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdnotacred ADD CONSTRAINT pk_kdnotacred PRIMARY KEY (c1, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdnotacred02 ON keplersc.kdnotacred USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdnotacred03 ON keplersc.kdnotacred USING btree (c1, c12, c13, c14, c15, c16) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdnotacred04 ON keplersc.kdnotacred USING btree (c1, c16) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdnotacred IS 'Notas de Crédito';
COMMENT ON COLUMN keplersc.kdnotacred.c9 IS 'ISAN';
COMMENT ON COLUMN keplersc.kdnotacred.c8 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdnotacred.c7 IS 'Folio';
COMMENT ON COLUMN keplersc.kdnotacred.c6 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdnotacred.c5 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdnotacred.c4 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdnotacred.c3 IS 'Genero';
COMMENT ON COLUMN keplersc.kdnotacred.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdnotacred.c16 IS 'Folio Factura';
COMMENT ON COLUMN keplersc.kdnotacred.c15 IS 'Tipo Factura';
COMMENT ON COLUMN keplersc.kdnotacred.c14 IS 'Grupo Factura';
COMMENT ON COLUMN keplersc.kdnotacred.c13 IS 'Naturaleza Factura';
COMMENT ON COLUMN keplersc.kdnotacred.c12 IS 'Genero Factura';
COMMENT ON COLUMN keplersc.kdnotacred.c11 IS 'Total';
COMMENT ON COLUMN keplersc.kdnotacred.c10 IS 'IVA';
COMMENT ON COLUMN keplersc.kdnotacred.c1 IS 'Sucursal';

