CREATE  TABLE keplersc.kduxe (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 numeric NOT NULL DEFAULT 0,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 numeric(10,2) NOT NULL DEFAULT 0,
  c14 numeric(10,2) NOT NULL DEFAULT 0,
  c15 numeric(10,5) NOT NULL DEFAULT 0,
  c16 numeric(10,5) NOT NULL DEFAULT 0,
  c17 character varying NULL,
  cve_prov_pago character varying(7) NOT NULL DEFAULT ''::character varying,
  doc_refer_compl character varying(40) NOT NULL DEFAULT ''::character varying,
  fecha_comprobacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  monto_rollback numeric(10,2) NOT NULL DEFAULT 0,
  iva_rollback numeric(10,2) NOT NULL DEFAULT 0,
  fecha_rollback timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  hora_comprobacion character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kduxe ON keplersc.kduxe USING btree (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduxe02 ON keplersc.kduxe USING btree (c1, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kduxe IS 'cuentas por cobrar o pagar';
COMMENT ON COLUMN keplersc.kduxe.monto_rollback IS 'Importe Rollback ( Modulo Gastos - Transfers )';
COMMENT ON COLUMN keplersc.kduxe.iva_rollback IS 'Monto IVA Rollback ( Modulo Gastos - Transfers )';
COMMENT ON COLUMN keplersc.kduxe.hora_comprobacion IS 'Hora Auxiliar CxP ( Modulo Gastos ) e.g. Transfer Rollback';
COMMENT ON COLUMN keplersc.kduxe.fecha_rollback IS 'Fecha Rollback ( Modulo Gastos - Transfers )';
COMMENT ON COLUMN keplersc.kduxe.fecha_comprobacion IS 'Fecha Comprobacion CxP ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxe.doc_refer_compl IS 'Documento Referencia Complemento ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxe.cve_prov_pago IS 'Clave Proveedor de Pago ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kduxe.c9 IS 'Folio operacion';
COMMENT ON COLUMN keplersc.kduxe.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kduxe.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kduxe.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kduxe.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kduxe.c4 IS 'Partida o Documento';
COMMENT ON COLUMN keplersc.kduxe.c3 IS 'Factura';
COMMENT ON COLUMN keplersc.kduxe.c2 IS 'Clave Cliente/Proveedor';
COMMENT ON COLUMN keplersc.kduxe.c17 IS 'estatus(C=Cancelado)';
COMMENT ON COLUMN keplersc.kduxe.c16 IS '% Cobranza';
COMMENT ON COLUMN keplersc.kduxe.c15 IS 'Intereses Moratorios';
COMMENT ON COLUMN keplersc.kduxe.c14 IS 'Monto IVA';
COMMENT ON COLUMN keplersc.kduxe.c13 IS 'Importe';
COMMENT ON COLUMN keplersc.kduxe.c12 IS 'Fecha Vencimiento';
COMMENT ON COLUMN keplersc.kduxe.c11 IS 'Fecha Expedicion';
COMMENT ON COLUMN keplersc.kduxe.c10 IS 'Partida';
COMMENT ON COLUMN keplersc.kduxe.c1 IS 'Sucursal';

