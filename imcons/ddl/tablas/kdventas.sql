CREATE  TABLE keplersc.kdventas (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 character varying(18) NOT NULL DEFAULT ''::character varying,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 character varying(7) NOT NULL DEFAULT ''::character varying,
  c17 character varying(5) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(4) NOT NULL DEFAULT ''::character varying,
  c21 character varying(10) NOT NULL DEFAULT ''::character varying,
  c22 character varying(10) NOT NULL DEFAULT ''::character varying,
  c23 character varying(10) NOT NULL DEFAULT ''::character varying,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c31 numeric(15,2) NOT NULL DEFAULT 0,
  c32 numeric(15,2) NOT NULL DEFAULT 0,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 numeric(15,2) NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 numeric(15,2) NOT NULL DEFAULT 0,
  contrato_gmac_ally character varying(15) NULL DEFAULT ''::character(1),
  codigo_cancelacion character varying(1) NULL DEFAULT ''::character(1)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdventas ADD CONSTRAINT pk_kdventas PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdventas02 ON keplersc.kdventas USING btree (c1, c4, c5, c6, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas03 ON keplersc.kdventas USING btree (c1, c14, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas04 ON keplersc.kdventas USING btree (c1, c21, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas05 ON keplersc.kdventas USING btree (c1, c16, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas06 ON keplersc.kdventas USING btree (c1, c17, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas07 ON keplersc.kdventas USING btree (c1, c14, c22, c23, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdventas08 ON keplersc.kdventas USING btree (c1, c13, c9, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdventas IS 'Ventas';
COMMENT ON COLUMN keplersc.kdventas.contrato_gmac_ally IS 'Numero de contrato GMAC o ALLY';
COMMENT ON COLUMN keplersc.kdventas.codigo_cancelacion IS 'Codigo de la razon en cancelacion de factura';
COMMENT ON COLUMN keplersc.kdventas.c9 IS 'Fecha factura';
COMMENT ON COLUMN keplersc.kdventas.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdventas.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdventas.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdventas.c5 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdventas.c4 IS 'Genero';
COMMENT ON COLUMN keplersc.kdventas.c36 IS 'Subsidio';
COMMENT ON COLUMN keplersc.kdventas.c35 IS 'Seguro de automovil';
COMMENT ON COLUMN keplersc.kdventas.c34 IS 'Gatrantía extendida';
COMMENT ON COLUMN keplersc.kdventas.c33 IS 'Accesorios';
COMMENT ON COLUMN keplersc.kdventas.c32 IS 'Gastos adminstrativos';
COMMENT ON COLUMN keplersc.kdventas.c31 IS 'Descuento';
COMMENT ON COLUMN keplersc.kdventas.c30 IS 'Fecha de compra';
COMMENT ON COLUMN keplersc.kdventas.c3 IS 'Partida';
COMMENT ON COLUMN keplersc.kdventas.c29 IS 'Costo';
COMMENT ON COLUMN keplersc.kdventas.c28 IS 'Flotilla';
COMMENT ON COLUMN keplersc.kdventas.c26 IS 'Importe';
COMMENT ON COLUMN keplersc.kdventas.c25 IS 'IVA';
COMMENT ON COLUMN keplersc.kdventas.c24 IS 'ISAN';
COMMENT ON COLUMN keplersc.kdventas.c23 IS 'Vestiduras';
COMMENT ON COLUMN keplersc.kdventas.c22 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdventas.c21 IS 'Linea';
COMMENT ON COLUMN keplersc.kdventas.c20 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdventas.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdventas.c19 IS 'nuevo o Usado';
COMMENT ON COLUMN keplersc.kdventas.c18 IS 'Marca';
COMMENT ON COLUMN keplersc.kdventas.c17 IS 'Tipo de operacion';
COMMENT ON COLUMN keplersc.kdventas.c16 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdventas.c15 IS 'Empresa';
COMMENT ON COLUMN keplersc.kdventas.c14 IS 'Clave del vehiculo';
COMMENT ON COLUMN keplersc.kdventas.c13 IS 'Coach';
COMMENT ON COLUMN keplersc.kdventas.c11 IS 'Clave del cliente';
COMMENT ON COLUMN keplersc.kdventas.c10 IS 'Status: 0 Alta; 10 Baja';
COMMENT ON COLUMN keplersc.kdventas.c1 IS 'Sucursal';

