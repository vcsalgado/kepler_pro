CREATE  TABLE keplersc.kdordbit (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 character varying(8) NOT NULL DEFAULT ''::character varying,
  c7 character varying(70) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordbit ADD CONSTRAINT pk_kdordbit PRIMARY KEY (c1, c2, c3, c4);

