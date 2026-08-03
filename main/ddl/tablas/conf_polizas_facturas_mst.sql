CREATE  TABLE keplersc.conf_polizas_facturas_mst (
  id_tipo_factura character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion_factura character varying(50) NOT NULL DEFAULT ''::character varying,
  tipo_poliza character varying(1) NOT NULL DEFAULT ''::character varying,
  descripcion_poliza character varying(100) NOT NULL DEFAULT ''::character varying,
  referencia_poliza character varying(100) NOT NULL DEFAULT ''::character varying,
  conceptos_origen character varying(200) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT conf_polizas_facturas_mst_unique UNIQUE (id_tipo_factura)
) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.tipo_poliza IS 'Tipo de poliza Diario, Ingreso, Egreso';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.referencia_poliza IS 'Referencia de la poliza';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.id_tipo_factura IS 'Identificador del tipo de factura';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.descripcion_poliza IS 'Descripcion de la poliza';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.descripcion_factura IS 'Descripcion factura';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_mst.conceptos_origen IS 'Cadena con los conceptos e importes de la factura original';

