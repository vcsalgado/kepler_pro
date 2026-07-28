CREATE  TABLE keplersc.kdvinsretencion (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvinsretencion ADD CONSTRAINT pk_kdvinsretencion PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdvinsretencion.c1 IS 'Ultimos 8 digitos';

