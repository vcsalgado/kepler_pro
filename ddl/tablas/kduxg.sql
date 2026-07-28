CREATE  TABLE keplersc.kduxg (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  cve_prov_pago character varying(7) NOT NULL DEFAULT ''::character varying,
  st_x_comprobar character varying(1) NOT NULL DEFAULT ''::character varying,
  doc_refer_compl character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_comprobacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  cargos_ivaret numeric(10,2) NOT NULL DEFAULT 0,
  cargos_isrret numeric(10,2) NOT NULL DEFAULT 0,
  cargos_iepstras numeric(10,2) NOT NULL DEFAULT 0,
  cargos_otroimptoa numeric(10,2) NOT NULL DEFAULT 0,
  cargos_otroimptob numeric(10,2) NOT NULL DEFAULT 0,
  cargos_totalimptoret numeric(10,2) NOT NULL DEFAULT 0,
  cargos_totalimptotras numeric(10,2) NOT NULL DEFAULT 0,
  cargos_subtotal numeric(10,2) NOT NULL DEFAULT 0,
  abonos_ivaret numeric(10,2) NOT NULL DEFAULT 0,
  abonos_isrret numeric(10,2) NOT NULL DEFAULT 0,
  abonos_iepstras numeric(10,2) NOT NULL DEFAULT 0,
  abonos_otroimptoa numeric(10,2) NOT NULL DEFAULT 0,
  abonos_otroimptob numeric(10,2) NOT NULL DEFAULT 0,
  abonos_totalimptoret numeric(10,2) NOT NULL DEFAULT 0,
  abonos_totalimptotras numeric(10,2) NOT NULL DEFAULT 0,
  abonos_subtotal numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kduxg ON keplersc.kduxg USING btree (c1, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduxg02 ON keplersc.kduxg USING btree (c1, c10, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduxg03 ON keplersc.kduxg USING btree (c1, c10, c2, c3, c11, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduxg04 ON keplersc.kduxg USING btree (c1, c10, c2, c3, c12, c4, c5) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kduxg IS 'cuentas por cobrar o pagar';
COMMENT ON COLUMN keplersc.kduxg.st_x_comprobar IS 'ST x Comprobar - [S] Por Comprobar, [X] Comprobado ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxg.fecha_comprobacion IS 'Fecha Comprobacion CxP ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxg.doc_refer_compl IS 'Documento Referencia Complemento ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxg.cve_prov_pago IS 'Clave Proveedor de Pago ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxg.cargos_totalimptotras IS 'Total impuesto trasladado';
COMMENT ON COLUMN keplersc.kduxg.cargos_totalimptoret IS 'Total impuesto retenido';
COMMENT ON COLUMN keplersc.kduxg.cargos_subtotal IS 'Subtotal';
COMMENT ON COLUMN keplersc.kduxg.cargos_otroimptob IS 'Otro impuesto B';
COMMENT ON COLUMN keplersc.kduxg.cargos_otroimptoa IS 'Otro impuesto A';
COMMENT ON COLUMN keplersc.kduxg.cargos_ivaret IS 'IVA Retenido';
COMMENT ON COLUMN keplersc.kduxg.cargos_isrret IS 'isr Retenido';
COMMENT ON COLUMN keplersc.kduxg.cargos_iepstras IS 'IEPS Trasladado';
COMMENT ON COLUMN keplersc.kduxg.c9 IS 'IVA Abonos';
COMMENT ON COLUMN keplersc.kduxg.c8 IS 'IVA Cargos';
COMMENT ON COLUMN keplersc.kduxg.c7 IS 'Abonos';
COMMENT ON COLUMN keplersc.kduxg.c6 IS 'Cargos';
COMMENT ON COLUMN keplersc.kduxg.c5 IS 'Documento o Partida';
COMMENT ON COLUMN keplersc.kduxg.c4 IS 'Factura';
COMMENT ON COLUMN keplersc.kduxg.c3 IS 'Clave Cliente / Proveedor';
COMMENT ON COLUMN keplersc.kduxg.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kduxg.c12 IS 'Fecha Vencimiento';
COMMENT ON COLUMN keplersc.kduxg.c11 IS 'Fecha Expedicion';
COMMENT ON COLUMN keplersc.kduxg.c10 IS '0=Sin saldar, 10=Saldado';
COMMENT ON COLUMN keplersc.kduxg.c1 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kduxg.abonos_totalimptotras IS 'Total impuesto trasladado';
COMMENT ON COLUMN keplersc.kduxg.abonos_totalimptoret IS 'Total impuesto retenido';
COMMENT ON COLUMN keplersc.kduxg.abonos_subtotal IS 'Subtotal';
COMMENT ON COLUMN keplersc.kduxg.abonos_otroimptob IS 'Otro impuesto B';
COMMENT ON COLUMN keplersc.kduxg.abonos_otroimptoa IS 'Otro impuesto A';
COMMENT ON COLUMN keplersc.kduxg.abonos_ivaret IS 'IVA Retenido';
COMMENT ON COLUMN keplersc.kduxg.abonos_isrret IS 'isr Retenido';
COMMENT ON COLUMN keplersc.kduxg.abonos_iepstras IS 'IEPS Trasladado';

