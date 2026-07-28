CREATE  TABLE keplersc.kdsercampana (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 character varying(7) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsercampana ADD CONSTRAINT pk_kdsercampana PRIMARY KEY (c2, c3);
CREATE INDEX IF NOT EXISTS sindkdsercampana03 ON keplersc.kdsercampana USING btree (c1, c4, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdsercampana04 ON keplersc.kdsercampana USING btree (c2, c4, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdsercampana05 ON keplersc.kdsercampana USING btree (c6, c4, c5, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdsercampana06 ON keplersc.kdsercampana USING btree (c3, c4, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdsercampana02 ON keplersc.kdsercampana USING btree (c1, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsercampana IS 'Campanas de servicio';
COMMENT ON COLUMN keplersc.kdsercampana.c9 IS 'Otro distribucion';
COMMENT ON COLUMN keplersc.kdsercampana.c8 IS 'Folio de la orden';
COMMENT ON COLUMN keplersc.kdsercampana.c7 IS 'Tipo de orden';
COMMENT ON COLUMN keplersc.kdsercampana.c6 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdsercampana.c5 IS 'Fecha de realizacion';
COMMENT ON COLUMN keplersc.kdsercampana.c4 IS '0 Pendiente; 10 Realizada; 15 Otro distribuidor';
COMMENT ON COLUMN keplersc.kdsercampana.c3 IS 'Clave campana';
COMMENT ON COLUMN keplersc.kdsercampana.c2 IS 'VIN';
COMMENT ON COLUMN keplersc.kdsercampana.c1 IS 'Ultimos 8 digitos serie';

