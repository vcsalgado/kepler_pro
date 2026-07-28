CREATE  TABLE keplersc.ifz_bp_citas (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  folio_cita character varying(20) NOT NULL DEFAULT ''::character varying,
  id_cita integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_citas_unique UNIQUE (id_cita)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_citas ADD CONSTRAINT ifz_bp_citas_pk PRIMARY KEY (sucursal, folio_cita);
COMMENT ON TABLE keplersc.ifz_bp_citas IS 'Tabla intermedia Citas Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_citas.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_citas.id_cita IS 'Id Cita en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_citas.folio_cita IS 'Folio Cita';

