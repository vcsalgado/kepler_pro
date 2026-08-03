CREATE  TABLE keplersc.conf_polizas_facturas_det (
  id_tipo_factura character varying(10) NOT NULL DEFAULT ''::character varying,
  tipo_asiento character varying(1) NOT NULL DEFAULT ''::character varying,
  cuenta character varying(20) NOT NULL,
  complemento_cuenta character varying(20) NOT NULL DEFAULT ''::character varying,
  descripcion_partida character varying(100) NOT NULL DEFAULT ''::character varying,
  referencia_partida character varying(100) NOT NULL DEFAULT ''::character varying,
  tipo_movto character varying(4) NOT NULL DEFAULT ''::character varying,
  id_concepto character varying(10) NOT NULL DEFAULT ''::character varying,
  cuenta_grupo character varying(1) NOT NULL DEFAULT 'N'::character varying,
  cuenta_divisible character varying(1) NOT NULL DEFAULT 'N'::character varying,
  campo_cuenta_plantilla character varying(3) NOT NULL DEFAULT ''::character varying,
  costo_inventario character varying(1) NOT NULL DEFAULT 'N'::character varying,
  CONSTRAINT conf_polizas_facturas_det_unique UNIQUE (id_tipo_factura, tipo_movto, id_concepto, tipo_asiento, cuenta)
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.conf_polizas_facturas_det IS 'Maestro de Confguracion de contable de las polizas con base en el tipo de factura';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.tipo_movto IS 'Provision, Pago';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.tipo_asiento IS 'Tipo de Asiento [C]argo o [A]bono';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.referencia_partida IS 'Referencia de la partida';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.id_tipo_factura IS 'Identificador del tipo de factura';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.descripcion_partida IS 'Descripcion de la partida';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.cuenta_grupo IS 'La cuenta se puede cambiar por otra dentro del mismo grupo de la  mayor';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.cuenta_divisible IS 'Cuenta se puede dividir en otras';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.cuenta IS 'Cuenta contable';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.costo_inventario IS 'La cuenta afecta inventarios';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.complemento_cuenta IS 'Complemento de la cuenta';
COMMENT ON COLUMN keplersc.conf_polizas_facturas_det.campo_cuenta_plantilla IS 'Tomar cuenta del campo indicado en kdmm';

