CREATE  TABLE keplersc.kdmarca (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmarca ADD CONSTRAINT pk_kdmarca PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdmarca.c2 IS 'desc';
COMMENT ON COLUMN keplersc.kdmarca.c1 IS 'clave';

