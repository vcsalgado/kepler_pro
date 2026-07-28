CREATE  TABLE keplersc.ifz_bp_citas_estatus (
  id_estatus integer NOT NULL DEFAULT 0,
  dscr_estatus character varying(20) NOT NULL DEFAULT ''::character varying,
  id_estatus_bp character varying(10) NOT NULL DEFAULT ''::character varying,
  dscr_estatus_bp character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_citas_estatus ADD CONSTRAINT ifz_bp_citas_estatus_pk PRIMARY KEY (id_estatus);
COMMENT ON TABLE keplersc.ifz_bp_citas_estatus IS 'Tabla Interface GM-BP - Gestionar Estatus Citas';
COMMENT ON COLUMN keplersc.ifz_bp_citas_estatus.id_estatus_bp IS 'Id Estatus en BP';
COMMENT ON COLUMN keplersc.ifz_bp_citas_estatus.id_estatus IS 'Id Estatus en GM';
COMMENT ON COLUMN keplersc.ifz_bp_citas_estatus.dscr_estatus_bp IS 'Descripcion Estatus en BP';
COMMENT ON COLUMN keplersc.ifz_bp_citas_estatus.dscr_estatus IS 'Descripcion Estatus en GM';

