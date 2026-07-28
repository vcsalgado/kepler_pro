CREATE  TABLE keplersc.kdmediocontacto (
  c1 numeric NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdmediocontacto IS 'Medios de contacto';
COMMENT ON COLUMN keplersc.kdmediocontacto.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdmediocontacto.c1 IS 'Clave';

