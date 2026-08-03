CREATE  TABLE keplersc.kdfe33params (
  c1 character varying(15) NOT NULL DEFAULT ''::character varying,
  c2 character varying(120) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdfe33params ADD CONSTRAINT pk_kdfe33params PRIMARY KEY (c1);

