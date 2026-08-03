CREATE  TABLE keplersc.kdmarcas (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmarcas ADD CONSTRAINT pk_kdmarcas PRIMARY KEY (c1);

