CREATE  TABLE keplersc.kdtoper (
  c1 character varying(5) NOT NULL,
  c2 character varying(40) NOT NULL,
  c3 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtoper.c3 IS 'Orden predeterminado';
COMMENT ON COLUMN keplersc.kdtoper.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtoper.c1 IS 'Clave';

