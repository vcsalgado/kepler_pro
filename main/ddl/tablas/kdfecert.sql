CREATE  TABLE keplersc.kdfecert (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying,
  c3 character varying(100) NOT NULL DEFAULT ''::character varying,
  c4 character varying(100) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfecert ADD CONSTRAINT pk_kdfecert PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdfecert02 ON keplersc.kdfecert USING btree (c8, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfecert03 ON keplersc.kdfecert USING btree (c9, c8, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfecert04 ON keplersc.kdfecert USING btree (c3, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdfecert05 ON keplersc.kdfecert USING btree (c4, c1, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdfecert.c9 IS 'Ini Vigencia';
COMMENT ON COLUMN keplersc.kdfecert.c8 IS 'Estatus 1 o 0';
COMMENT ON COLUMN keplersc.kdfecert.c5 IS 'Contrasena';
COMMENT ON COLUMN keplersc.kdfecert.c4 IS 'Clave publica';
COMMENT ON COLUMN keplersc.kdfecert.c3 IS 'Clave privada';
COMMENT ON COLUMN keplersc.kdfecert.c2 IS 'Numero certificado';
COMMENT ON COLUMN keplersc.kdfecert.c10 IS 'Fin Vigencia';
COMMENT ON COLUMN keplersc.kdfecert.c1 IS 'Clave sucursal';

