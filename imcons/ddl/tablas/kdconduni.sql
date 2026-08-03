CREATE  TABLE keplersc.kdconduni (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdconduni IS 'Cat logo condicion de unidad';
COMMENT ON COLUMN keplersc.kdconduni.c2 IS 'Descripcion condicion';
COMMENT ON COLUMN keplersc.kdconduni.c1 IS 'Clave condicion';

