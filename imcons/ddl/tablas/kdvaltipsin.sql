CREATE  TABLE keplersc.kdvaltipsin (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvaltipsin ADD CONSTRAINT pk_kdvaltipsin PRIMARY KEY (c1, c2);
COMMENT ON COLUMN keplersc.kdvaltipsin.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdvaltipsin.c2 IS 'Clave Valor';
COMMENT ON COLUMN keplersc.kdvaltipsin.c1 IS 'IdSintoma';

