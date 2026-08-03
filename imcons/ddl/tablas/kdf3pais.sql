CREATE  TABLE keplersc.kdf3pais (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(80) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3pais ADD CONSTRAINT pk_kdf3pais PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdf3pais.c7 IS 'Country phone code';
COMMENT ON COLUMN keplersc.kdf3pais.c6 IS 'Agrupaciones';
COMMENT ON COLUMN keplersc.kdf3pais.c5 IS 'Validacion de Registro';
COMMENT ON COLUMN keplersc.kdf3pais.c4 IS 'Formato de Registro de ID';
COMMENT ON COLUMN keplersc.kdf3pais.c3 IS 'Formato CP';
COMMENT ON COLUMN keplersc.kdf3pais.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3pais.c1 IS 'Clave';

