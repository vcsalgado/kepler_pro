CREATE  TABLE keplersc.kdsercatubica (
  concesionario character varying NOT NULL DEFAULT ''::character varying,
  clave character varying(7) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsercatubica IS 'Catalogo de ubicaciones de servicio por concesionario';
COMMENT ON COLUMN keplersc.kdsercatubica.descripcion IS 'Descripcion de la ubicacion del servicio';
COMMENT ON COLUMN keplersc.kdsercatubica.concesionario IS 'Clave del concesionario';
COMMENT ON COLUMN keplersc.kdsercatubica.clave IS 'Clave de la ubicacion de servicio';

