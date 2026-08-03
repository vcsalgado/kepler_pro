CREATE  TABLE keplersc.ifz_bp_tipounidad (
  cve_tipounidad character varying(30) NOT NULL DEFAULT ''::character varying,
  id_unidad integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_tipounidad_unique UNIQUE (id_unidad)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_tipounidad ADD CONSTRAINT ifz_bp_tipounidad_pk PRIMARY KEY (cve_tipounidad);
COMMENT ON TABLE keplersc.ifz_bp_tipounidad IS 'Tabla intermedia tipo unidad Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_tipounidad.id_unidad IS 'Id de la unidad en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_tipounidad.cve_tipounidad IS 'Cve compuesta Marca-Modelo-Anio-Transmision';

