CREATE  TABLE keplersc.kdmdocscompr (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 character varying(30) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying,
  c14 character varying(4) NOT NULL DEFAULT ''::character varying,
  c15 character varying(40) NOT NULL DEFAULT ''::character varying,
  c16 character varying(10) NOT NULL DEFAULT ''::character varying,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  ctopto character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdmdocscompr ON keplersc.kdmdocscompr USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdmdocscompr02 ON keplersc.kdmdocscompr USING btree (c13, c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdmdocscompr IS 'Movimientos contables por documento comprobado';
COMMENT ON COLUMN keplersc.kdmdocscompr.ctopto IS 'Concepto Presupuesto';
COMMENT ON COLUMN keplersc.kdmdocscompr.c9 IS 'Descripcion de la cuenta';
COMMENT ON COLUMN keplersc.kdmdocscompr.c8 IS 'Cuenta contable';
COMMENT ON COLUMN keplersc.kdmdocscompr.c7 IS 'No Partida';
COMMENT ON COLUMN keplersc.kdmdocscompr.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdmdocscompr.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdmdocscompr.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdmdocscompr.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdmdocscompr.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdmdocscompr.c18 IS 'Monto incluyendo el IVA';
COMMENT ON COLUMN keplersc.kdmdocscompr.c17 IS 'Monto de IVA';
COMMENT ON COLUMN keplersc.kdmdocscompr.c16 IS 'Departamento';
COMMENT ON COLUMN keplersc.kdmdocscompr.c15 IS 'Referencia o numero de factura';
COMMENT ON COLUMN keplersc.kdmdocscompr.c14 IS 'Subcuenta contable';
COMMENT ON COLUMN keplersc.kdmdocscompr.c13 IS 'Clave proyecto';
COMMENT ON COLUMN keplersc.kdmdocscompr.c12 IS 'Clave concepto';
COMMENT ON COLUMN keplersc.kdmdocscompr.c11 IS 'Monto';
COMMENT ON COLUMN keplersc.kdmdocscompr.c10 IS 'Tipo C=Cargo A=Abono';
COMMENT ON COLUMN keplersc.kdmdocscompr.c1 IS 'Sucursal';

