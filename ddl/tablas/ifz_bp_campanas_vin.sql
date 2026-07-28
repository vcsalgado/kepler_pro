CREATE  TABLE keplersc.ifz_bp_campanas_vin (
  serie character varying(20) NOT NULL,
  clave_campana character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_solicitud timestamp without time zone NOT NULL DEFAULT now()
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS ifz_bp_campanas_vin_serie_idx ON keplersc.ifz_bp_campanas_vin USING btree (serie) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.ifz_bp_campanas_vin IS 'Registro de resultados de consulta de campanas po vin a través de bp';
COMMENT ON COLUMN keplersc.ifz_bp_campanas_vin.serie IS 'Serie del vehiculo';
COMMENT ON COLUMN keplersc.ifz_bp_campanas_vin.fecha_solicitud IS 'Fecha en que se realiza la solicitud a bp';
COMMENT ON COLUMN keplersc.ifz_bp_campanas_vin.clave_campana IS 'Clave de la campana';

