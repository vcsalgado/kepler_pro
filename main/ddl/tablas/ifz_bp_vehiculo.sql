CREATE  TABLE keplersc.ifz_bp_vehiculo (
  cve_vehiculo character varying(30) NOT NULL DEFAULT ''::character varying,
  id_vehiculo integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_vehiculo_unique UNIQUE (id_vehiculo)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_vehiculo ADD CONSTRAINT ifz_bp_vehiculo_pk PRIMARY KEY (cve_vehiculo);
COMMENT ON TABLE keplersc.ifz_bp_vehiculo IS 'Tabla intermedia vehiculos Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_vehiculo.id_vehiculo IS 'Id del Vehiculo en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_vehiculo.cve_vehiculo IS 'Cve Vehiculo - VIN';

