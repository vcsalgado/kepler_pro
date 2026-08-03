CREATE  TABLE keplersc.ifz_bp_facturas (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  folio_orden character varying(20) NOT NULL DEFAULT ''::character varying,
  folio_factura character varying(20) NOT NULL DEFAULT ''::character varying,
  id_factura integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_facturas_unique_f UNIQUE (sucursal, folio_factura),
  CONSTRAINT ifz_bp_facturas_unique_if UNIQUE (id_factura)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_facturas ADD CONSTRAINT ifz_bp_facturas_pk PRIMARY KEY (sucursal, folio_orden);
COMMENT ON TABLE keplersc.ifz_bp_facturas IS 'Tabla intermedia Facturas Ordenes Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_facturas.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_facturas.id_factura IS 'Id Factura en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_facturas.folio_orden IS 'Folio Compuesto (Tipo,Folio) de la Orden';
COMMENT ON COLUMN keplersc.ifz_bp_facturas.folio_factura IS 'Folio Compuesto (Gen,Nat,Gpo,Tipo,Folio) de la Factura';

