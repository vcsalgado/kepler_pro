CREATE  TABLE keplersc.kdtmktorigen (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtmktorigen IS 'Origen de contacto de TMKT';
COMMENT ON COLUMN keplersc.kdtmktorigen.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtmktorigen.c1 IS 'Clave';

