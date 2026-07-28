CREATE  TABLE keplersc.orgconfig (
  k_param character varying(20) NOT NULL DEFAULT ''::character varying,
  k_value character varying(80) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.orgconfig ADD CONSTRAINT pk_orgconfig PRIMARY KEY (k_param);

