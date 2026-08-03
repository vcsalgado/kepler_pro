CREATE  TABLE keplersc.kdpresupuestos (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  mes character varying(2) NOT NULL DEFAULT ''::character varying,
  cve_concepto character varying(10) NOT NULL DEFAULT ''::character varying,
  importe numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpresupuestos IS 'Presupuestos';
COMMENT ON COLUMN keplersc.kdpresupuestos.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdpresupuestos.mes IS 'Mes presupuesto';
COMMENT ON COLUMN keplersc.kdpresupuestos.importe IS 'Importe presupuestado';
COMMENT ON COLUMN keplersc.kdpresupuestos.cve_concepto IS 'Clave concepto presupuesto';
COMMENT ON COLUMN keplersc.kdpresupuestos.anio IS 'A o presupuesto';

