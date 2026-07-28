CREATE  TABLE keplersc.kdfepacs (
  c1 character varying(30) NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(100) NOT NULL DEFAULT ''::character varying,
  c8 character varying(80) NOT NULL DEFAULT ''::character varying,
  c9 character varying(80) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(100) NOT NULL DEFAULT ''::character varying,
  c13 character varying(60) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(80) NOT NULL DEFAULT ''::character varying,
  c16 character varying(60) NOT NULL DEFAULT ''::character varying,
  c17 character varying(80) NOT NULL DEFAULT ''::character varying,
  c18 character varying(80) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric NOT NULL DEFAULT 0,
  c21 character varying(4) NOT NULL DEFAULT ''::character varying,
  c22 character varying(4) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(200) NOT NULL DEFAULT ''::character varying,
  c25 character varying(200) NOT NULL DEFAULT ''::character varying,
  c26 character varying(200) NOT NULL DEFAULT ''::character varying,
  c27 character varying(200) NOT NULL DEFAULT ''::character varying,
  c28 character varying(200) NOT NULL DEFAULT ''::character varying,
  c29 character varying(200) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfepacs ADD CONSTRAINT pk_kdfepacs PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdfepacs02 ON keplersc.kdfepacs USING btree (c4, c5, c1) TABLESPACE pg_default;

