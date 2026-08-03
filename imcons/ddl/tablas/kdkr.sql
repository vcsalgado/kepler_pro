CREATE  TABLE keplersc.kdkr (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying(200) NOT NULL DEFAULT ''::character varying,
  c3 character varying(200) NOT NULL DEFAULT ''::character varying,
  c4 character varying(60) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(30) NOT NULL DEFAULT ''::character varying,
  c9 character varying(30) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdkr ON keplersc.kdkr USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdkr02 ON keplersc.kdkr USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdkr IS 'Roles';

