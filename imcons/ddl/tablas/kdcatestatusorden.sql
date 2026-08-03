CREATE  TABLE keplersc.kdcatestatusorden (
  c1 numeric NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatestatusorden IS 'catalogo de status de las ordenes de servicio';
COMMENT ON COLUMN keplersc.kdcatestatusorden.c2 IS 'descripcion';
COMMENT ON COLUMN keplersc.kdcatestatusorden.c1 IS 'estatus';

