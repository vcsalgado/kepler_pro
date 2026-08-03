CREATE  TABLE keplersc.cat_ctas_ppto (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  rango_ini character varying(20) NOT NULL DEFAULT ''::character varying,
  rango_fin character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.cat_ctas_ppto IS 'Catalogo de rangos de cuentas de presupuesto';
COMMENT ON COLUMN keplersc.cat_ctas_ppto.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.cat_ctas_ppto.rango_ini IS 'Rango inicial de las cuentas de presupuesto';
COMMENT ON COLUMN keplersc.cat_ctas_ppto.rango_fin IS 'Rango final de las cuentas de presupuesto';
COMMENT ON COLUMN keplersc.cat_ctas_ppto.anio IS 'A�o de rangos de presupuesto';

