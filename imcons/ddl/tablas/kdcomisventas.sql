CREATE  TABLE keplersc.kdcomisventas (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(18) NOT NULL DEFAULT ''::character varying,
  c12 character varying(30) NOT NULL DEFAULT ''::character varying,
  c13 character varying(6) NOT NULL DEFAULT ''::character varying,
  c14 character varying(4) NOT NULL DEFAULT ''::character varying,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 numeric NOT NULL DEFAULT 0,
  c18 character varying(7) NOT NULL DEFAULT ''::character varying,
  c19 numeric(10,2) NOT NULL DEFAULT 0,
  c20 numeric(10,2) NOT NULL DEFAULT 0,
  c21 numeric(10,2) NOT NULL DEFAULT 0,
  c22 numeric(10,2) NOT NULL DEFAULT 0,
  c23 numeric(10,2) NOT NULL DEFAULT 0,
  c24 numeric(10,2) NOT NULL DEFAULT 0,
  c25 numeric(10,2) NOT NULL DEFAULT 0,
  c26 numeric(10,2) NOT NULL DEFAULT 0,
  c27 numeric(10,2) NOT NULL DEFAULT 0,
  c28 numeric(10,2) NOT NULL DEFAULT 0,
  c29 numeric(10,2) NOT NULL DEFAULT 0,
  c30 numeric(10,2) NOT NULL DEFAULT 0,
  c31 numeric(10,2) NOT NULL DEFAULT 0,
  c32 numeric(10,2) NOT NULL DEFAULT 0,
  c33 numeric(10,2) NOT NULL DEFAULT 0,
  c34 numeric(10,2) NOT NULL DEFAULT 0,
  c35 numeric(10,2) NOT NULL DEFAULT 0,
  c36 numeric(10,2) NOT NULL DEFAULT 0,
  c37 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomisventas ADD CONSTRAINT pk_kdcomisventas PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdcomisventas02 ON keplersc.kdcomisventas USING btree (c1, c2, c3, c4, c5, c9, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomisventas03 ON keplersc.kdcomisventas USING btree (c1, c2, c3, c4, c9, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcomisventas IS 'Comisiones Ventas';
COMMENT ON COLUMN keplersc.kdcomisventas.c9 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcomisventas.c8 IS '0 Alta 10 Baja';
COMMENT ON COLUMN keplersc.kdcomisventas.c7 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdcomisventas.c6 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdcomisventas.c5 IS '0 Ventas 10 Toma  20 Toma entre compra y venta';
COMMENT ON COLUMN keplersc.kdcomisventas.c4 IS 'Asesor';
COMMENT ON COLUMN keplersc.kdcomisventas.c37 IS 'Total de comisiones';
COMMENT ON COLUMN keplersc.kdcomisventas.c36 IS 'Descuento asesor tmkt';
COMMENT ON COLUMN keplersc.kdcomisventas.c35 IS 'Comision antes tmkt';
COMMENT ON COLUMN keplersc.kdcomisventas.c34 IS 'Comision por semana';
COMMENT ON COLUMN keplersc.kdcomisventas.c33 IS 'Comision por accesorios';
COMMENT ON COLUMN keplersc.kdcomisventas.c32 IS 'Comision por ingresos extra';
COMMENT ON COLUMN keplersc.kdcomisventas.c31 IS 'Comision por seguros';
COMMENT ON COLUMN keplersc.kdcomisventas.c30 IS 'Comision por gastos administrativos';
COMMENT ON COLUMN keplersc.kdcomisventas.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdcomisventas.c29 IS 'Comision por linea';
COMMENT ON COLUMN keplersc.kdcomisventas.c28 IS 'Comision por edad';
COMMENT ON COLUMN keplersc.kdcomisventas.c27 IS 'Comision o descuento por traslado';
COMMENT ON COLUMN keplersc.kdcomisventas.c26 IS 'Comision sin bonos';
COMMENT ON COLUMN keplersc.kdcomisventas.c25 IS 'Utilidad bruta de accesorios';
COMMENT ON COLUMN keplersc.kdcomisventas.c24 IS 'Subsidio';
COMMENT ON COLUMN keplersc.kdcomisventas.c23 IS 'Nota de descuento';
COMMENT ON COLUMN keplersc.kdcomisventas.c22 IS 'Garantia extendida';
COMMENT ON COLUMN keplersc.kdcomisventas.c21 IS 'Seguro';
COMMENT ON COLUMN keplersc.kdcomisventas.c20 IS 'Gastos administrativos';
COMMENT ON COLUMN keplersc.kdcomisventas.c2 IS 'Anio';
COMMENT ON COLUMN keplersc.kdcomisventas.c19 IS 'Utilidad Bruta';
COMMENT ON COLUMN keplersc.kdcomisventas.c18 IS 'Asesor TMKT';
COMMENT ON COLUMN keplersc.kdcomisventas.c17 IS 'Edad en inventario';
COMMENT ON COLUMN keplersc.kdcomisventas.c16 IS 'Traslado';
COMMENT ON COLUMN keplersc.kdcomisventas.c15 IS 'Linea';
COMMENT ON COLUMN keplersc.kdcomisventas.c14 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdcomisventas.c13 IS 'Nuevo o Usado';
COMMENT ON COLUMN keplersc.kdcomisventas.c12 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcomisventas.c11 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdcomisventas.c10 IS 'Tipo Operacion';
COMMENT ON COLUMN keplersc.kdcomisventas.c1 IS 'Sucursal';

