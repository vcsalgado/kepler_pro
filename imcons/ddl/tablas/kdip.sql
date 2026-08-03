CREATE  TABLE keplersc.kdip (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(70) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(70) NOT NULL DEFAULT ''::character varying,
  c6 character varying(70) NOT NULL DEFAULT ''::character varying,
  c7 character varying(70) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdip ON keplersc.kdip USING btree (c1) TABLESPACE pg_default;

