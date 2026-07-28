CREATE  TABLE keplersc.ifz_bp_ordenes (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  folio_orden character varying(20) NOT NULL DEFAULT ''::character varying,
  id_orden integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_ordenes_unique UNIQUE (id_orden)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_ordenes ADD CONSTRAINT ifz_bp_ordenes_pk PRIMARY KEY (sucursal, folio_orden);
COMMENT ON TABLE keplersc.ifz_bp_ordenes IS 'Tabla intermedia Ordenes Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes.id_orden IS 'Id Orden en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_ordenes.folio_orden IS 'Tipo y Folio de la Orden';

