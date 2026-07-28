CREATE  TABLE keplersc.kdmdocsnodeduc (
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
CREATE INDEX IF NOT EXISTS sindkdmdocsnodeduc02 ON keplersc.kdmdocsnodeduc USING btree (c13, c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdmdocsnodeduc ON keplersc.kdmdocsnodeduc USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdmdocsnodeduc IS 'Movimientos contables por documento No deducible';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.ctopto IS 'Concepto Presupuesto';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c9 IS 'Descripcion de la cuenta';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c8 IS 'Cuenta contable';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c7 IS 'No Partida';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c18 IS 'Monto incluyendo el IVA';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c17 IS 'Monto de IVA';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c16 IS 'Departamento';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c15 IS 'Referencia o numero de factura';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c14 IS 'Subcuenta contable';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c13 IS 'Clave proyecto';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c12 IS 'Clave concepto';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c11 IS 'Monto';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c10 IS 'Tipo C=Cargo A=Abono';
COMMENT ON COLUMN keplersc.kdmdocsnodeduc.c1 IS 'Sucursal';

