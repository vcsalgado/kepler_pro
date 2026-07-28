CREATE  TABLE keplersc.kdcorres (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(17) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying,
  c5 character varying(4) NOT NULL DEFAULT ''::character varying,
  c6 character varying(50) NOT NULL DEFAULT ''::character varying,
  c7 character varying(50) NOT NULL DEFAULT ''::character varying,
  c8 character varying(50) NOT NULL DEFAULT ''::character varying,
  c9 character varying(50) NOT NULL DEFAULT ''::character varying,
  c10 character varying(20) NOT NULL DEFAULT ''::character varying,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(20) NOT NULL DEFAULT ''::character varying,
  c15 character varying(20) NOT NULL DEFAULT ''::character varying,
  c16 character varying(50) NOT NULL DEFAULT ''::character varying,
  c17 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcorres ADD CONSTRAINT pk_kdcorres PRIMARY KEY (c1, c2);

