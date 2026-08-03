CREATE  TABLE keplersc.kdvencaidas (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(18) NOT NULL DEFAULT ''::character varying,
  c5 character varying(40) NOT NULL DEFAULT ''::character varying,
  c6 numeric(10,5) NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvencaidas ADD CONSTRAINT pk_kdvencaidas PRIMARY KEY (c1, c2, c3, c10, c11, c12);
CREATE INDEX IF NOT EXISTS sindkdvencaidas02 ON keplersc.kdvencaidas USING btree (c1, c11, c12) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvencaidas03 ON keplersc.kdvencaidas USING btree (c1, c4, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdvencaidas IS 'Ventas caidas';
COMMENT ON COLUMN keplersc.kdvencaidas.c9 IS 'Motivo';
COMMENT ON COLUMN keplersc.kdvencaidas.c8 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvencaidas.c7 IS 'Unitario';
COMMENT ON COLUMN keplersc.kdvencaidas.c6 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdvencaidas.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdvencaidas.c4 IS 'Clave de la pieza';
COMMENT ON COLUMN keplersc.kdvencaidas.c3 IS 'Partida';
COMMENT ON COLUMN keplersc.kdvencaidas.c2 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvencaidas.c12 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdvencaidas.c11 IS 'IdTipoOrden';
COMMENT ON COLUMN keplersc.kdvencaidas.c10 IS 'Origen';
COMMENT ON COLUMN keplersc.kdvencaidas.c1 IS 'Sucursal';

