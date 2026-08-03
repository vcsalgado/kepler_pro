CREATE  TABLE keplersc.kdccuentas (
  c1 character varying(20) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(3) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(3) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(15,2) NOT NULL DEFAULT 0,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 numeric(15,2) NOT NULL DEFAULT 0,
  c32 numeric(15,2) NOT NULL DEFAULT 0,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 numeric(15,2) NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 numeric(15,2) NOT NULL DEFAULT 0,
  c37 numeric(15,2) NOT NULL DEFAULT 0,
  c38 numeric(15,2) NOT NULL DEFAULT 0,
  c39 numeric(15,2) NOT NULL DEFAULT 0,
  c40 numeric(15,2) NOT NULL DEFAULT 0,
  c41 numeric(15,2) NOT NULL DEFAULT 0,
  c42 numeric(15,2) NOT NULL DEFAULT 0,
  c43 numeric(15,2) NOT NULL DEFAULT 0,
  c44 numeric(15,2) NOT NULL DEFAULT 0,
  c45 numeric(15,2) NOT NULL DEFAULT 0,
  c46 numeric(15,2) NOT NULL DEFAULT 0,
  c47 numeric(15,2) NOT NULL DEFAULT 0,
  c48 numeric(15,2) NOT NULL DEFAULT 0,
  c49 numeric(15,2) NOT NULL DEFAULT 0,
  c50 numeric(15,2) NOT NULL DEFAULT 0,
  c51 numeric(15,2) NOT NULL DEFAULT 0,
  c52 numeric(15,2) NOT NULL DEFAULT 0,
  c53 numeric(15,2) NOT NULL DEFAULT 0,
  c54 numeric(15,2) NOT NULL DEFAULT 0,
  c55 numeric(15,2) NOT NULL DEFAULT 0,
  c56 numeric(15,2) NOT NULL DEFAULT 0,
  c57 numeric(15,2) NOT NULL DEFAULT 0,
  c58 numeric(15,2) NOT NULL DEFAULT 0,
  c59 numeric(15,2) NOT NULL DEFAULT 0,
  c60 numeric(15,2) NOT NULL DEFAULT 0,
  c61 numeric(15,2) NOT NULL DEFAULT 0,
  c62 numeric(15,2) NOT NULL DEFAULT 0,
  c63 numeric(15,2) NOT NULL DEFAULT 0,
  c64 numeric(15,2) NOT NULL DEFAULT 0,
  c65 numeric(15,2) NOT NULL DEFAULT 0,
  c66 numeric(15,2) NOT NULL DEFAULT 0,
  c67 numeric(15,2) NOT NULL DEFAULT 0,
  c68 numeric(15,2) NOT NULL DEFAULT 0,
  c69 numeric(15,2) NOT NULL DEFAULT 0,
  c70 numeric(15,2) NOT NULL DEFAULT 0,
  c71 numeric(15,2) NOT NULL DEFAULT 0,
  c72 numeric(15,2) NOT NULL DEFAULT 0,
  c73 numeric(15,2) NOT NULL DEFAULT 0,
  c74 numeric(15,2) NOT NULL DEFAULT 0,
  c75 numeric(15,2) NOT NULL DEFAULT 0,
  c76 numeric(15,2) NOT NULL DEFAULT 0,
  c77 numeric(15,2) NOT NULL DEFAULT 0,
  c78 numeric(15,2) NOT NULL DEFAULT 0,
  c79 numeric(15,2) NOT NULL DEFAULT 0,
  c80 numeric(15,2) NOT NULL DEFAULT 0,
  c81 numeric(15,2) NOT NULL DEFAULT 0,
  c82 numeric(15,2) NOT NULL DEFAULT 0,
  c83 numeric(15,2) NOT NULL DEFAULT 0,
  c84 numeric(15,2) NOT NULL DEFAULT 0,
  c85 numeric(15,2) NOT NULL DEFAULT 0,
  c86 numeric(15,2) NOT NULL DEFAULT 0,
  c87 character varying(1) NOT NULL DEFAULT ''::character varying,
  c88 character varying(1) NOT NULL DEFAULT ''::character varying,
  c89 character varying(1) NOT NULL DEFAULT ''::character varying,
  c90 character varying(1) NOT NULL DEFAULT ''::character varying,
  c91 numeric(15,2) NOT NULL DEFAULT 0,
  c92 numeric(15,2) NOT NULL DEFAULT 0,
  c93 numeric(15,2) NOT NULL DEFAULT 0,
  c94 numeric(15,2) NOT NULL DEFAULT 0,
  c95 character varying(1) NOT NULL DEFAULT ''::character varying,
  c96 character varying(1) NOT NULL DEFAULT ''::character varying,
  c97 character varying(1) NOT NULL DEFAULT ''::character varying,
  c98 character varying(1) NOT NULL DEFAULT ''::character varying,
  c99 character varying(1) NOT NULL DEFAULT ''::character varying,
  c100 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdccuentas ON keplersc.kdccuentas USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdccuentas02 ON keplersc.kdccuentas USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdccuentas03 ON keplersc.kdccuentas USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdccuentas IS 'Cuentas Contables';
COMMENT ON COLUMN keplersc.kdccuentas.c86 IS 'suma de abonos en dólares en el mes 12';
COMMENT ON COLUMN keplersc.kdccuentas.c85 IS 'suma de abonos en dólares en el mes 11';
COMMENT ON COLUMN keplersc.kdccuentas.c84 IS 'suma de abonos en dólares en el mes 10';
COMMENT ON COLUMN keplersc.kdccuentas.c83 IS 'suma de abonos en dólares en el mes 9';
COMMENT ON COLUMN keplersc.kdccuentas.c82 IS 'suma de abonos en dólares en el mes 8';
COMMENT ON COLUMN keplersc.kdccuentas.c81 IS 'suma de abonos en dólares en el mes 7';
COMMENT ON COLUMN keplersc.kdccuentas.c80 IS 'suma de abonos en dólares en el mes 6';
COMMENT ON COLUMN keplersc.kdccuentas.c79 IS 'suma de abonos en dólares en el mes 5';
COMMENT ON COLUMN keplersc.kdccuentas.c78 IS 'suma de abonos en dólares en el mes 4';
COMMENT ON COLUMN keplersc.kdccuentas.c77 IS 'suma de abonos en dólares en el mes 3';
COMMENT ON COLUMN keplersc.kdccuentas.c76 IS 'suma de abonos en dólares en el mes 2';
COMMENT ON COLUMN keplersc.kdccuentas.c75 IS 'suma de abonos en dólares en el mes 1';
COMMENT ON COLUMN keplersc.kdccuentas.c74 IS 'suma de abonos en pesos en el mes 12';
COMMENT ON COLUMN keplersc.kdccuentas.c73 IS 'suma de abonos en pesos en el mes 11';
COMMENT ON COLUMN keplersc.kdccuentas.c72 IS 'suma de abonos en pesos en el mes 10';
COMMENT ON COLUMN keplersc.kdccuentas.c71 IS 'suma de abonos en pesos en el mes 9';
COMMENT ON COLUMN keplersc.kdccuentas.c70 IS 'suma de abonos en pesos en el mes 8';
COMMENT ON COLUMN keplersc.kdccuentas.c7 IS 'Clave de la moneda DLL=dólares PES=nuevos pesos';
COMMENT ON COLUMN keplersc.kdccuentas.c69 IS 'suma de abonos en pesos en el mes 7';
COMMENT ON COLUMN keplersc.kdccuentas.c68 IS 'suma de abonos en pesos en el mes 6';
COMMENT ON COLUMN keplersc.kdccuentas.c67 IS 'suma de abonos en pesos en el mes 5';
COMMENT ON COLUMN keplersc.kdccuentas.c66 IS 'suma de abonos en pesos en el mes 4';
COMMENT ON COLUMN keplersc.kdccuentas.c65 IS 'suma de abonos en pesos en el mes 3';
COMMENT ON COLUMN keplersc.kdccuentas.c64 IS 'suma de abonos en pesos en el mes 2';
COMMENT ON COLUMN keplersc.kdccuentas.c63 IS 'suma de abonos en pesos en el mes 1';
COMMENT ON COLUMN keplersc.kdccuentas.c62 IS 'saldo en dólares del mes diciembre';
COMMENT ON COLUMN keplersc.kdccuentas.c61 IS 'saldo en dólares del mes noviembre';
COMMENT ON COLUMN keplersc.kdccuentas.c60 IS 'saldo en dólares del mes octubre';
COMMENT ON COLUMN keplersc.kdccuentas.c6 IS 'Naturaleza D=Deudora A=Acreedora';
COMMENT ON COLUMN keplersc.kdccuentas.c59 IS 'saldo en dólares del mes septiembre';
COMMENT ON COLUMN keplersc.kdccuentas.c58 IS 'saldo en dólares del mes agosto';
COMMENT ON COLUMN keplersc.kdccuentas.c57 IS 'saldo en dólares del mes julio';
COMMENT ON COLUMN keplersc.kdccuentas.c56 IS 'saldo en dólares del mes junio';
COMMENT ON COLUMN keplersc.kdccuentas.c55 IS 'saldo en dólares del mes mayo';
COMMENT ON COLUMN keplersc.kdccuentas.c54 IS 'saldo en dólares del mes abril';
COMMENT ON COLUMN keplersc.kdccuentas.c53 IS 'saldo en dólares del mes marzo';
COMMENT ON COLUMN keplersc.kdccuentas.c52 IS 'saldo en dólares del mes febrero';
COMMENT ON COLUMN keplersc.kdccuentas.c51 IS 'saldo en dólares del mes enero';
COMMENT ON COLUMN keplersc.kdccuentas.c50 IS 'presupuesto del mes diciembre';
COMMENT ON COLUMN keplersc.kdccuentas.c49 IS 'presupuesto del mes noviembre';
COMMENT ON COLUMN keplersc.kdccuentas.c48 IS 'presupuesto del mes octubre';
COMMENT ON COLUMN keplersc.kdccuentas.c47 IS 'presupuesto del mes septiembre';
COMMENT ON COLUMN keplersc.kdccuentas.c46 IS 'presupuesto del mes agosto';
COMMENT ON COLUMN keplersc.kdccuentas.c45 IS 'presupuesto del mes julio';
COMMENT ON COLUMN keplersc.kdccuentas.c44 IS 'presupuesto del mes junio';
COMMENT ON COLUMN keplersc.kdccuentas.c43 IS 'presupuesto del mes mayo';
COMMENT ON COLUMN keplersc.kdccuentas.c42 IS 'presupuesto del mes abril';
COMMENT ON COLUMN keplersc.kdccuentas.c41 IS 'presupuesto del mes marzo';
COMMENT ON COLUMN keplersc.kdccuentas.c40 IS 'presupuesto del mes febrero';
COMMENT ON COLUMN keplersc.kdccuentas.c4 IS '1=Departamento especial 0=No';
COMMENT ON COLUMN keplersc.kdccuentas.c39 IS 'presupuesto del mes enero';
COMMENT ON COLUMN keplersc.kdccuentas.c38 IS 'suma de cargos en pesos del mes 12';
COMMENT ON COLUMN keplersc.kdccuentas.c37 IS 'suma de cargos en pesos del mes 11';
COMMENT ON COLUMN keplersc.kdccuentas.c36 IS 'suma de cargos en pesos del mes 10';
COMMENT ON COLUMN keplersc.kdccuentas.c35 IS 'suma de cargos en pesos del mes 9';
COMMENT ON COLUMN keplersc.kdccuentas.c34 IS 'suma de cargos en pesos del mes 8';
COMMENT ON COLUMN keplersc.kdccuentas.c33 IS 'suma de cargos en pesos del mes 7';
COMMENT ON COLUMN keplersc.kdccuentas.c32 IS 'suma de cargos en pesos del mes 6';
COMMENT ON COLUMN keplersc.kdccuentas.c31 IS 'suma de cargos en pesos del mes 5';
COMMENT ON COLUMN keplersc.kdccuentas.c30 IS 'suma de cargos en pesos del mes 4';
COMMENT ON COLUMN keplersc.kdccuentas.c3 IS 'Grupo AC AF AD PC PLP PD CC VTA CMV GTO GF IMP';
COMMENT ON COLUMN keplersc.kdccuentas.c29 IS 'suma de cargos en pesos del mes 3';
COMMENT ON COLUMN keplersc.kdccuentas.c28 IS 'suma de cargos en pesos del mes 2';
COMMENT ON COLUMN keplersc.kdccuentas.c27 IS 'suma de cargos en pesos del mes 1';
COMMENT ON COLUMN keplersc.kdccuentas.c26 IS 'saldo año anterior diciembre';
COMMENT ON COLUMN keplersc.kdccuentas.c25 IS 'saldo año anterior noviembre';
COMMENT ON COLUMN keplersc.kdccuentas.c24 IS 'saldo año anterior octubre';
COMMENT ON COLUMN keplersc.kdccuentas.c23 IS 'saldo año anterior septiembre';
COMMENT ON COLUMN keplersc.kdccuentas.c22 IS 'saldo año anterior agosto';
COMMENT ON COLUMN keplersc.kdccuentas.c21 IS 'saldo año anterior julio';
COMMENT ON COLUMN keplersc.kdccuentas.c20 IS 'saldo año anterior junio';
COMMENT ON COLUMN keplersc.kdccuentas.c2 IS 'Descripción de la cuenta';
COMMENT ON COLUMN keplersc.kdccuentas.c19 IS 'saldo año anterior mayo';
COMMENT ON COLUMN keplersc.kdccuentas.c18 IS 'saldo año anterior abril';
COMMENT ON COLUMN keplersc.kdccuentas.c17 IS 'saldo año anterior marzo';
COMMENT ON COLUMN keplersc.kdccuentas.c16 IS 'saldo año anterior febrero';
COMMENT ON COLUMN keplersc.kdccuentas.c15 IS 'saldo año anterior enero';
COMMENT ON COLUMN keplersc.kdccuentas.c14 IS 'Saldo inicial pesos';
COMMENT ON COLUMN keplersc.kdccuentas.c11 IS 'Saldo inicial dólares';
COMMENT ON COLUMN keplersc.kdccuentas.c100 IS 'Afecta IETU';
COMMENT ON COLUMN keplersc.kdccuentas.c1 IS 'No. de cuenta';

