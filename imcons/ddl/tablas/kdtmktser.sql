CREATE  TABLE keplersc.kdtmktser (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(8) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(80) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(80) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying,
  c14 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c15 numeric NOT NULL DEFAULT 0,
  c16 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c17 character varying(2) NOT NULL DEFAULT ''::character varying,
  c18 numeric NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktser ADD CONSTRAINT pk_kdtmktser PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdtmktser02 ON keplersc.kdtmktser USING btree (c1, c3, c4, c5, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser03 ON keplersc.kdtmktser USING btree (c1, c3, c15, c16, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser04 ON keplersc.kdtmktser USING btree (c1, c5, c7, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser05 ON keplersc.kdtmktser USING btree (c1, c3, c14, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser06 ON keplersc.kdtmktser USING btree (c1, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtmktser IS 'Servicio Telemarketing';
COMMENT ON COLUMN keplersc.kdtmktser.c9 IS 'Observacion 1';
COMMENT ON COLUMN keplersc.kdtmktser.c8 IS 'Folio de cita';
COMMENT ON COLUMN keplersc.kdtmktser.c7 IS 'VIN';
COMMENT ON COLUMN keplersc.kdtmktser.c6 IS 'Razon para recontacto';
COMMENT ON COLUMN keplersc.kdtmktser.c5 IS 'Status';
COMMENT ON COLUMN keplersc.kdtmktser.c4 IS 'Fecha para el recontacto';
COMMENT ON COLUMN keplersc.kdtmktser.c3 IS 'Asesor TMKT';
COMMENT ON COLUMN keplersc.kdtmktser.c2 IS 'Folio';
COMMENT ON COLUMN keplersc.kdtmktser.c18 IS 'Tipo servicio TMKT';
COMMENT ON COLUMN keplersc.kdtmktser.c17 IS 'Hora para recontacto en el dia';
COMMENT ON COLUMN keplersc.kdtmktser.c16 IS 'Fecha en que se registro en pantalla';
COMMENT ON COLUMN keplersc.kdtmktser.c15 IS 'Registro en pantalla';
COMMENT ON COLUMN keplersc.kdtmktser.c14 IS 'Fecha en que se recontacto al cliente';
COMMENT ON COLUMN keplersc.kdtmktser.c13 IS 'Folio de orden';
COMMENT ON COLUMN keplersc.kdtmktser.c12 IS 'Tipo de orden';
COMMENT ON COLUMN keplersc.kdtmktser.c11 IS 'Observacion 3';
COMMENT ON COLUMN keplersc.kdtmktser.c10 IS 'Observacion 2';
COMMENT ON COLUMN keplersc.kdtmktser.c1 IS 'Sucursal';

