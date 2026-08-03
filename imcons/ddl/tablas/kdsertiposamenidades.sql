CREATE  TABLE keplersc.kdsertiposamenidades (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsertiposamenidades IS 'Tipo de Amenidad';
COMMENT ON COLUMN keplersc.kdsertiposamenidades.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdsertiposamenidades.c1 IS 'Clave';

