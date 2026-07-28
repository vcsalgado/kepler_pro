CREATE  TABLE keplersc.kdcatpaqlealtad (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,5) NOT NULL DEFAULT 0,
  c3 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatpaqlealtad ADD CONSTRAINT pk_kdcatpaqlealtad PRIMARY KEY (c1);

