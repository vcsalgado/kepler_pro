CREATE  TABLE keplersc.kdtisan (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtisan ADD CONSTRAINT pk_kdtisan PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdtisan IS 'Tipo de ISAN';
COMMENT ON COLUMN keplersc.kdtisan.c2 IS 'Desripcion Tipo';
COMMENT ON COLUMN keplersc.kdtisan.c1 IS 'Clave Tipo';

