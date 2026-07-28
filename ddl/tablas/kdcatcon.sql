CREATE  TABLE keplersc.kdcatcon (
  c1 character varying(7) NOT NULL,
  c2 character varying(50) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatcon ADD CONSTRAINT pk_kdcatcon PRIMARY KEY (c1);

