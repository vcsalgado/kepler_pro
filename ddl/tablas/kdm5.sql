CREATE  TABLE keplersc.kdm5 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,6) NOT NULL DEFAULT 0,
  c14 character varying(40) NOT NULL DEFAULT ''::character varying,
  c15 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c16 numeric NULL,
  c17 numeric(15,2) NULL,
  cve_prov_oper character varying(7) NOT NULL DEFAULT ''::character varying,
  cve_prov_pago character varying(7) NOT NULL DEFAULT ''::character varying,
  cta_deposito character varying(20) NOT NULL DEFAULT ''::character varying,
  st_x_comprobar character varying(1) NOT NULL DEFAULT ''::character varying,
  usr_comprobacion character varying(21) NOT NULL DEFAULT ''::character varying,
  fecha_comprobacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  hora_comprobacion character varying(10) NOT NULL DEFAULT ''::character varying,
  doc_refer_compl character varying(200) NOT NULL DEFAULT ''::character varying,
  fecha_registro timestamp without time zone NULL DEFAULT now()
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm5 ON keplersc.kdm5 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm5 IS 'Documentos a Saldar por documento';
COMMENT ON COLUMN keplersc.kdm5.usr_comprobacion IS 'Usuario Comprobacion / Evaluacion ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.st_x_comprobar IS '[N] Evaluado Not Passed ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.hora_comprobacion IS 'Hora Auxiliar CxP ( Modulo Gastos ) e.g. Transfer Rollback';
COMMENT ON COLUMN keplersc.kdm5.fecha_registro IS 'Fecha y hora de registreo de operacion ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.fecha_comprobacion IS 'Fecha Comprobacion / Evaluacion CxP ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.doc_refer_compl IS 'Clave Proveedor de Operacion ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.cve_prov_pago IS 'Clave Proveedor de Pago ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.cve_prov_oper IS 'Clave Proveedor de Operacion ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.cta_deposito IS 'Cuenta Deposito Proveedor de Pago ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdm5.c9 IS 'Numero grupo';
COMMENT ON COLUMN keplersc.kdm5.c8 IS 'Naturaleza docto';
COMMENT ON COLUMN keplersc.kdm5.c7 IS 'Numero partida';
COMMENT ON COLUMN keplersc.kdm5.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm5.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm5.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm5.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm5.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm5.c17 IS 'Otros Cargos';
COMMENT ON COLUMN keplersc.kdm5.c16 IS 'Numero de Docto';
COMMENT ON COLUMN keplersc.kdm5.c15 IS 'Vencimiento';
COMMENT ON COLUMN keplersc.kdm5.c14 IS 'Referencia documento';
COMMENT ON COLUMN keplersc.kdm5.c13 IS 'Monto abono o IVA';
COMMENT ON COLUMN keplersc.kdm5.c12 IS 'Monto cargo o monto';
COMMENT ON COLUMN keplersc.kdm5.c11 IS 'Folio documento';
COMMENT ON COLUMN keplersc.kdm5.c10 IS 'Numero tipo';
COMMENT ON COLUMN keplersc.kdm5.c1 IS 'Sucursal';

