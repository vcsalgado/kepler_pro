CREATE  TABLE keplersc.kdstatuspun (
  c1 character varying(1) NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdstatuspun IS 'status puntos';
COMMENT ON COLUMN keplersc.kdstatuspun.c2 IS 'descripcion status';
COMMENT ON COLUMN keplersc.kdstatuspun.c1 IS 'clave status';

