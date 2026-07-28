CREATE  TABLE keplersc.ifz_bp_ordenes_factura (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  folio_orden character varying(20) NOT NULL DEFAULT ''::character varying,
  id_orden integer NOT NULL DEFAULT 0,
  folio_factura character varying(20) NOT NULL DEFAULT ''::character varying,
  id_factura integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_ordenes_factura_unique_f UNIQUE (folio_factura),
  CONSTRAINT ifz_bp_ordenes_factura_unique_if UNIQUE (id_factura),
  CONSTRAINT ifz_bp_ordenes_factura_unique_io UNIQUE (id_orden)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_ordenes_factura ADD CONSTRAINT ifz_bp_ordenes_factura_pk PRIMARY KEY (sucursal, folio_orden);
COMMENT ON TABLE keplersc.ifz_bp_ordenes_factura IS 'Tabla intermedia Ordenes - Facturas Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_factura.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_factura.id_orden IS 'Id Orden en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_factura.id_factura IS 'Id Factura en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_factura.folio_orden IS 'Tipo y Folio de la Orden';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes_factura.folio_factura IS 'Folio Factura';

