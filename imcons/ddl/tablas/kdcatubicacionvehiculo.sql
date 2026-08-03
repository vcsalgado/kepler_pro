CREATE  TABLE keplersc.kdcatubicacionvehiculo (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatubicacionvehiculo IS 'catalogo ubicaciones vehiculo';
COMMENT ON COLUMN keplersc.kdcatubicacionvehiculo.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcatubicacionvehiculo.c1 IS 'Identificador';

