CREATE  TABLE keplersc.kdtipoordentipopuntos (
  c1 character varying NULL,
  c2 character varying NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtipoordentipopuntos IS 'relacion tipo orden tipo puntos';
COMMENT ON COLUMN keplersc.kdtipoordentipopuntos.c2 IS 'tipo punto';
COMMENT ON COLUMN keplersc.kdtipoordentipopuntos.c1 IS 'tipo orden';

