CREATE  TABLE keplersc.kdcatconpres (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  cve_concepto character varying(10) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatconpres IS 'Catalofo conceptos de presupuesto';
COMMENT ON COLUMN keplersc.kdcatconpres.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdcatconpres.descripcion IS 'Descripcion del concepto';
COMMENT ON COLUMN keplersc.kdcatconpres.cve_concepto IS 'Clave concepto';

