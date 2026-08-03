CREATE  TABLE keplersc.kdmy (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 character varying(9) NOT NULL DEFAULT ''::character varying,
  c5 character varying(9) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmy ADD CONSTRAINT pk_kdmy PRIMARY KEY (c1);

