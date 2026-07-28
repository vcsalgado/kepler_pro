CREATE  TABLE keplersc.kdstatustabulacion (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdstatustabulacion.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdstatustabulacion.c1 IS 'Estatus';

