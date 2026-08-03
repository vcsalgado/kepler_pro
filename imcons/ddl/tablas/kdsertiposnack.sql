CREATE  TABLE keplersc.kdsertiposnack (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsertiposnack IS 'Tipo de Snack';
COMMENT ON COLUMN keplersc.kdsertiposnack.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdsertiposnack.c1 IS 'Clave';

