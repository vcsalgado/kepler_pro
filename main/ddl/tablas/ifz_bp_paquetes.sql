CREATE  TABLE keplersc.ifz_bp_paquetes (
  cve_paquete character varying(20) NOT NULL DEFAULT ''::character varying,
  id_paquete integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_paquetes_unique UNIQUE (id_paquete)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_paquetes ADD CONSTRAINT ifz_bp_paquetes_pk PRIMARY KEY (cve_paquete);
COMMENT ON TABLE keplersc.ifz_bp_paquetes IS 'Tabla intermedia Paquetes Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_paquetes.id_paquete IS 'Id Paquete en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_paquetes.cve_paquete IS 'Complex CvePaq : Marca + Modelo + CvePaq';

