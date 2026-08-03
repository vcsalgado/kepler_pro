CREATE  TABLE keplersc.kdxe (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(4) NOT NULL DEFAULT ''::character varying,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 numeric(7,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 character varying(7) NOT NULL DEFAULT ''::character varying,
  c23 character varying(10) NOT NULL DEFAULT ''::character varying,
  c24 character varying(7) NOT NULL DEFAULT ''::character varying,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 double precision NOT NULL DEFAULT 0,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdxe ON keplersc.kdxe USING btree (c1, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxe02 ON keplersc.kdxe USING btree (c1, c8, c7, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxe03 ON keplersc.kdxe USING btree (c1, c2, c8, c7, c3, c4, c5, c6, c20) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxe04 ON keplersc.kdxe USING btree (c1, c3, c4, c5, c6, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxe05 ON keplersc.kdxe USING btree (c1, c2, c3, c4, c5, c16, c7, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxe06 ON keplersc.kdxe USING btree (c1, c3, c7, c4, c5, c6, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdxe.c7 IS 'Fecha docto';
COMMENT ON COLUMN keplersc.kdxe.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdxe.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdxe.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdxe.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdxe.c2 IS 'Proveedor';
COMMENT ON COLUMN keplersc.kdxe.c1 IS 'Sucursal';

