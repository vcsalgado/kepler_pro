CREATE  TABLE keplersc.ifz_bp_colores (
  cve_color character varying(5) NOT NULL DEFAULT ''::character varying,
  dscr_color character varying(20) NOT NULL DEFAULT ''::character varying,
  id_color integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_colores_unique UNIQUE (id_color)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_colores ADD CONSTRAINT ifz_bp_colores_pk PRIMARY KEY (cve_color);
COMMENT ON TABLE keplersc.ifz_bp_colores IS 'Tabla intermedia colores Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_colores.id_color IS 'Id del color en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_colores.dscr_color IS 'Descripcion Color';
COMMENT ON COLUMN keplersc.ifz_bp_colores.cve_color IS 'Cve Color';

