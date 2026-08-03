CREATE  TABLE keplersc.kdcattipocitas (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcattipocitas IS 'catalogo tipo de citas';
COMMENT ON COLUMN keplersc.kdcattipocitas.c2 IS 'descripcion';
COMMENT ON COLUMN keplersc.kdcattipocitas.c1 IS 'tipo';

