CREATE  TABLE keplersc.kdf3cp (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(5) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3cp ADD CONSTRAINT pk_kdf3cp PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdf3cp IS 'f3 CP';
COMMENT ON COLUMN keplersc.kdf3cp.c4 IS 'Localidad';
COMMENT ON COLUMN keplersc.kdf3cp.c3 IS 'Municipio';
COMMENT ON COLUMN keplersc.kdf3cp.c2 IS 'Estado';
COMMENT ON COLUMN keplersc.kdf3cp.c1 IS 'CP';

