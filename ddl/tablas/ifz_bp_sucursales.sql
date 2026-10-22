CREATE  TABLE keplersc.ifz_bp_sucursales (
  id_suc integer NOT NULL,
  cve_suc character varying(10) NOT NULL,
  suc_nomb character varying(35) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_sucursales ADD CONSTRAINT ifz_bp_sucursales_pk PRIMARY KEY (id_suc, cve_suc);
COMMENT ON TABLE keplersc.ifz_bp_sucursales IS 'Tabla de Sucursales Registradas en BP';
COMMENT ON COLUMN keplersc.ifz_bp_sucursales.suc_nomb IS 'Nombre Sucursal BP';
COMMENT ON COLUMN keplersc.ifz_bp_sucursales.id_suc IS 'id Sucursal BP';
COMMENT ON COLUMN keplersc.ifz_bp_sucursales.cve_suc IS 'Sucursal Inmotion';

