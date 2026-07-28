CREATE  TABLE keplersc.kdlealtadheader (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric(40,5) NOT NULL DEFAULT 0,
  c5 numeric(40,5) NOT NULL DEFAULT 0,
  c6 numeric(40,5) NOT NULL DEFAULT 0,
  c7 numeric(40,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdlealtadheader ADD CONSTRAINT pk_kdlealtadheader PRIMARY KEY (c1, c2, c3);

