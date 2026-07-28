CREATE  TABLE keplersc.ifz_bp_vehiculo_ty (
  cve_vehiculo character varying(30) NOT NULL DEFAULT ''::character varying,
  cve_suc character varying(10) NOT NULL,
  id_vehiculo integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_vehiculo_ty_unique UNIQUE (id_vehiculo)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_vehiculo_ty ADD CONSTRAINT ifz_bp_vehiculo_ty_pk PRIMARY KEY (cve_vehiculo, cve_suc);
COMMENT ON TABLE keplersc.ifz_bp_vehiculo_ty IS 'Tabla intermedia vehiculos Interface TY-BP';
COMMENT ON COLUMN keplersc.ifz_bp_vehiculo_ty.id_vehiculo IS 'Id del Vehiculo en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_vehiculo_ty.cve_vehiculo IS 'Cve Vehiculo - VIN';
COMMENT ON COLUMN keplersc.ifz_bp_vehiculo_ty.cve_suc IS 'Sucursal Inmotion';

