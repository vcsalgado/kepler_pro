CREATE  TABLE keplersc.kd_ident_proceso (
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  clave character varying NOT NULL DEFAULT ''::character varying,
  "desc" character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kd_ident_proceso IS 'acciones de servicio';

