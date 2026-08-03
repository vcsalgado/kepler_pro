CREATE  TABLE keplersc.kdku (
  c1 character varying(30) NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 character varying(20) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying,
  c8 character varying(80) NOT NULL DEFAULT ''::character varying,
  c9 character varying(80) NOT NULL DEFAULT ''::character varying,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 character varying(60) NOT NULL DEFAULT ''::character varying,
  c12 character varying(60) NOT NULL DEFAULT ''::character varying,
  c13 character varying(20) NOT NULL DEFAULT ''::character varying,
  c14 character varying(20) NOT NULL DEFAULT ''::character varying,
  c15 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c16 character varying(5) NOT NULL DEFAULT ''::character varying,
  c17 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 numeric NOT NULL DEFAULT 0,
  c20 character varying(80) NOT NULL DEFAULT ''::character varying,
  c21 character varying(80) NOT NULL DEFAULT ''::character varying,
  c22 character varying(80) NOT NULL DEFAULT ''::character varying,
  c23 character varying(80) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 character varying(1) NOT NULL DEFAULT ''::character varying,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdku ON keplersc.kdku USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdku02 ON keplersc.kdku USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdku IS 'Usuarios
Usuarios';

