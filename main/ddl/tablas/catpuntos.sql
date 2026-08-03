CREATE  TABLE keplersc.catpuntos (
  c1 character varying NULL,
  c2 character varying NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.catpuntos IS 'Catalogo de Puntos';
COMMENT ON COLUMN keplersc.catpuntos.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.catpuntos.c1 IS 'Clave';

