CREATE  TABLE keplersc.ifz_bp_accionescampo (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  cve_accion character varying(30) NOT NULL DEFAULT ''::character varying,
  tipo_accion character varying(20) NOT NULL DEFAULT ''::character varying,
  id_accion integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_accionescampo_unique UNIQUE (id_accion)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_accionescampo ADD CONSTRAINT ifz_bp_accionescampo_pk PRIMARY KEY (sucursal, cve_accion, tipo_accion);
COMMENT ON TABLE keplersc.ifz_bp_accionescampo IS 'Tabla intermedia Acciones Campo Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_accionescampo.tipo_accion IS 'Tipo Accion Campo - Campaña';
COMMENT ON COLUMN keplersc.ifz_bp_accionescampo.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_accionescampo.id_accion IS 'Id Accion Campo en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_accionescampo.cve_accion IS 'Clave Accion Campo';

