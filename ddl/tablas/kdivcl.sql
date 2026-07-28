CREATE  TABLE keplersc.kdivcl (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(16) NOT NULL DEFAULT ''::character varying,
  c16 character varying(16) NOT NULL DEFAULT ''::character varying,
  c17 character varying(16) NOT NULL DEFAULT ''::character varying,
  c18 character varying(16) NOT NULL DEFAULT ''::character varying,
  c19 character varying(16) NOT NULL DEFAULT ''::character varying,
  c20 character varying(16) NOT NULL DEFAULT ''::character varying,
  c21 character varying(16) NOT NULL DEFAULT ''::character varying,
  c22 character varying(16) NOT NULL DEFAULT ''::character varying,
  c23 character varying(16) NOT NULL DEFAULT ''::character varying,
  c24 character varying(16) NOT NULL DEFAULT ''::character varying,
  c25 character varying(16) NOT NULL DEFAULT ''::character varying,
  c26 character varying(16) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdivcl ADD CONSTRAINT pk_kdivcl PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdivcl IS 'Catalogo de cuentas autos';
COMMENT ON COLUMN keplersc.kdivcl.c3 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdivcl.c26 IS 'Precio de Venta traspasos';
COMMENT ON COLUMN keplersc.kdivcl.c25 IS 'Costo de Venta traspasos';
COMMENT ON COLUMN keplersc.kdivcl.c24 IS 'IVA a la compra';
COMMENT ON COLUMN keplersc.kdivcl.c23 IS 'IVA a la venta';
COMMENT ON COLUMN keplersc.kdivcl.c22 IS 'Precio de Venta';
COMMENT ON COLUMN keplersc.kdivcl.c21 IS 'Costo de Venta';
COMMENT ON COLUMN keplersc.kdivcl.c20 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdivcl.c2 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdivcl.c19 IS 'Proveedores';
COMMENT ON COLUMN keplersc.kdivcl.c18 IS 'Ventas Contado';
COMMENT ON COLUMN keplersc.kdivcl.c17 IS 'Costo F & I';
COMMENT ON COLUMN keplersc.kdivcl.c16 IS 'Ventas F & I';
COMMENT ON COLUMN keplersc.kdivcl.c15 IS 'Notas de descuento';
COMMENT ON COLUMN keplersc.kdivcl.c1 IS 'Clave vehiculo';

