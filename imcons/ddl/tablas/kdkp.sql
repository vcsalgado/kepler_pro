CREATE  TABLE keplersc.kdkp (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying(200) NOT NULL DEFAULT ''::character varying,
  c3 character varying(200) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(30) NOT NULL DEFAULT ''::character varying,
  c6 character varying(30) NOT NULL DEFAULT ''::character varying,
  c7 character varying(80) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(80) NOT NULL DEFAULT ''::character varying,
  c12 character varying(80) NOT NULL DEFAULT ''::character varying,
  c13 character varying(80) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdkp ON keplersc.kdkp USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdkp02 ON keplersc.kdkp USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdkp IS 'Perfiles';

