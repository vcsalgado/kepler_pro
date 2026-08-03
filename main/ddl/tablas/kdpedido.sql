CREATE  TABLE keplersc.kdpedido (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(5) NOT NULL DEFAULT ''::character varying,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,6) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(8,4) NOT NULL DEFAULT 0,
  c24 numeric NOT NULL DEFAULT 0,
  c25 numeric(8,4) NOT NULL DEFAULT 0,
  c26 character varying(1) NOT NULL DEFAULT ''::character varying,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 numeric(10,5) NOT NULL DEFAULT 0,
  c32 numeric NOT NULL DEFAULT 0,
  c33 numeric NOT NULL DEFAULT 0,
  c34 numeric NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 numeric(15,2) NOT NULL DEFAULT 0,
  c37 numeric(15,2) NOT NULL DEFAULT 0,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  c41 character varying(1) NOT NULL DEFAULT ''::character varying,
  c42 character varying(5) NOT NULL DEFAULT ''::character varying,
  c43 numeric(15,2) NOT NULL DEFAULT 0,
  c44 numeric(15,2) NOT NULL DEFAULT 0,
  c45 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedido ADD CONSTRAINT pk_kdpedido PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdpedido02 ON keplersc.kdpedido USING btree (c1, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpedido IS 'Pedido de vehículo para venta';
COMMENT ON COLUMN keplersc.kdpedido.c9 IS 'Clave del cliente';
COMMENT ON COLUMN keplersc.kdpedido.c8 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdpedido.c7 IS 'Folio';
COMMENT ON COLUMN keplersc.kdpedido.c6 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdpedido.c5 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdpedido.c45 IS 'Extras 3';
COMMENT ON COLUMN keplersc.kdpedido.c44 IS 'Extras 2';
COMMENT ON COLUMN keplersc.kdpedido.c43 IS 'Extras 1';
COMMENT ON COLUMN keplersc.kdpedido.c42 IS 'Coach';
COMMENT ON COLUMN keplersc.kdpedido.c41 IS 'Factura Int y Cob Realizada';
COMMENT ON COLUMN keplersc.kdpedido.c40 IS 'Factura PVA 3 realizada';
COMMENT ON COLUMN keplersc.kdpedido.c4 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdpedido.c39 IS 'Factura PVA 2 realizada';
COMMENT ON COLUMN keplersc.kdpedido.c38 IS 'Factura PVA 1 realizada';
COMMENT ON COLUMN keplersc.kdpedido.c37 IS 'Total factura PVA3';
COMMENT ON COLUMN keplersc.kdpedido.c36 IS 'Total factura PVA2';
COMMENT ON COLUMN keplersc.kdpedido.c35 IS 'Total factura PVA1';
COMMENT ON COLUMN keplersc.kdpedido.c34 IS 'Factura de PVA de Garantía Extendida';
COMMENT ON COLUMN keplersc.kdpedido.c33 IS 'Factura de PVA de Accesorios';
COMMENT ON COLUMN keplersc.kdpedido.c32 IS 'Factura de PVA de gastos Admon';
COMMENT ON COLUMN keplersc.kdpedido.c31 IS 'Intereses moratorios';
COMMENT ON COLUMN keplersc.kdpedido.c30 IS 'Descuento';
COMMENT ON COLUMN keplersc.kdpedido.c3 IS 'Genero';
COMMENT ON COLUMN keplersc.kdpedido.c29 IS 'Es Flotilla';
COMMENT ON COLUMN keplersc.kdpedido.c28 IS 'Cobranza';
COMMENT ON COLUMN keplersc.kdpedido.c27 IS 'Intereses';
COMMENT ON COLUMN keplersc.kdpedido.c26 IS 'Amortizacion variable';
COMMENT ON COLUMN keplersc.kdpedido.c25 IS 'Porciento de cobranza sin IVA';
COMMENT ON COLUMN keplersc.kdpedido.c24 IS 'Plazo';
COMMENT ON COLUMN keplersc.kdpedido.c23 IS 'Porciento de interes';
COMMENT ON COLUMN keplersc.kdpedido.c22 IS 'Monto a financiar';
COMMENT ON COLUMN keplersc.kdpedido.c21 IS 'Fecha inicio doctos';
COMMENT ON COLUMN keplersc.kdpedido.c20 IS 'Seguro del automovil';
COMMENT ON COLUMN keplersc.kdpedido.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdpedido.c19 IS 'Garantia extndida';
COMMENT ON COLUMN keplersc.kdpedido.c18 IS 'Accesorios';
COMMENT ON COLUMN keplersc.kdpedido.c17 IS 'Gastos administrativos';
COMMENT ON COLUMN keplersc.kdpedido.c16 IS 'Bonificación';
COMMENT ON COLUMN keplersc.kdpedido.c15 IS 'Subsidio';
COMMENT ON COLUMN keplersc.kdpedido.c14 IS 'Importe';
COMMENT ON COLUMN keplersc.kdpedido.c13 IS 'IVA';
COMMENT ON COLUMN keplersc.kdpedido.c12 IS 'ISAN';
COMMENT ON COLUMN keplersc.kdpedido.c11 IS 'Clave de la operacion';
COMMENT ON COLUMN keplersc.kdpedido.c10 IS 'Clave del vendedor';
COMMENT ON COLUMN keplersc.kdpedido.c1 IS 'Sucursal';

