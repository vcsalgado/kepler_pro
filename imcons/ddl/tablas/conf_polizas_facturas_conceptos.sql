CREATE  TABLE keplersc.conf_polizas_facturas_conceptos (
  id_concepto character varying(10) NOT NULL,
  descripcion character varying(20) NOT NULL,
  id_campo_m1 character varying(30) NOT NULL,
  id_campo_ui character varying(30) NOT NULL DEFAULT ''::character varying,
  CONSTRAINT conf_polizas_facturas_conceptos_unique UNIQUE (id_concepto)
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.conf_polizas_facturas_conceptos IS 'Configuracion de conceptos en facturas';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_conceptos.id_concepto IS 'Identificador del concepto';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_conceptos.id_campo_ui IS 'Identificador de campo en interfaz grafica';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_conceptos.id_campo_m1 IS 'Identificador del campo en datos de sistema';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_conceptos.descripcion IS 'Descripcion del concepto';

