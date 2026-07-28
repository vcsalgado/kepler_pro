CREATE  TABLE keplersc.kdtvr6 (
  c1 character varying(15) NOT NULL DEFAULT ''::character varying,
  c2 character varying(15) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtvr6 ADD CONSTRAINT kdtvr6_pk PRIMARY KEY (c1);

