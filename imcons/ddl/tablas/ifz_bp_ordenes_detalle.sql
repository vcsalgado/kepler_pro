CREATE  TABLE keplersc.ifz_bp_ordenes_detalle (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  folio_orden character varying(20) NOT NULL DEFAULT ''::character varying,
  consec integer NOT NULL DEFAULT 0,
  id_orden integer NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_ordenes_detalle ADD CONSTRAINT ifz_bp_ordenes_detalle_pk PRIMARY KEY (sucursal, folio_orden, consec);
COMMENT ON TABLE keplersc.ifz_bp_ordenes_detalle IS 'Tabla intermedia Ordenes Detalle Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_detalle.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_detalle.id_orden IS 'Id Orden en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_detalle.folio_orden IS 'Tipo y Folio de la Orden';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_detalle.consec IS 'Consecutivo - Puntos Registrados';

