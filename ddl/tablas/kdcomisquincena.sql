CREATE  TABLE keplersc.kdcomisquincena (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(7) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 character varying(18) NOT NULL DEFAULT ''::character varying,
  c13 character varying(30) NOT NULL DEFAULT ''::character varying,
  c14 character varying(6) NOT NULL DEFAULT ''::character varying,
  c15 character varying(4) NOT NULL DEFAULT ''::character varying,
  c16 character varying(10) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 numeric NOT NULL DEFAULT 0,
  c19 character varying(7) NOT NULL DEFAULT ''::character varying,
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
  c37 numeric(10,2) NOT NULL DEFAULT 0,
  c38 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomisquincena ADD CONSTRAINT pk_kdcomisquincena PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdcomisquincena02 ON keplersc.kdcomisquincena USING btree (c1, c2, c3, c4, c5, c9, c6, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomisquincena03 ON keplersc.kdcomisquincena USING btree (c1, c2, c3, c4, c9, c5, c6, c7, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcomisquincena IS 'Vendedores comisiones quincenales';
COMMENT ON COLUMN keplersc.kdcomisquincena.c9 IS '0 Alta 10 Baja';
COMMENT ON COLUMN keplersc.kdcomisquincena.c8 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdcomisquincena.c7 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdcomisquincena.c6 IS '0 Venta 10 Toma 20 entre compra y venta';
COMMENT ON COLUMN keplersc.kdcomisquincena.c5 IS 'Asesor';
COMMENT ON COLUMN keplersc.kdcomisquincena.c4 IS 'Quincena mes';
COMMENT ON COLUMN keplersc.kdcomisquincena.c38 IS 'Total comisiones';
COMMENT ON COLUMN keplersc.kdcomisquincena.c37 IS 'Descuento asesor tmkt';
COMMENT ON COLUMN keplersc.kdcomisquincena.c36 IS 'Comis antes tmkt';
COMMENT ON COLUMN keplersc.kdcomisquincena.c35 IS 'Comis semana';
COMMENT ON COLUMN keplersc.kdcomisquincena.c34 IS 'Comis accesorios';
COMMENT ON COLUMN keplersc.kdcomisquincena.c33 IS 'Comis ingresos extra';
COMMENT ON COLUMN keplersc.kdcomisquincena.c32 IS 'Comis seguro';
COMMENT ON COLUMN keplersc.kdcomisquincena.c31 IS 'Comis gastos adtvos';
COMMENT ON COLUMN keplersc.kdcomisquincena.c30 IS 'Comis linea';
COMMENT ON COLUMN keplersc.kdcomisquincena.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdcomisquincena.c29 IS 'Comis edad';
COMMENT ON COLUMN keplersc.kdcomisquincena.c28 IS 'Comis o descto por traslado';
COMMENT ON COLUMN keplersc.kdcomisquincena.c27 IS 'Comis sin bonos';
COMMENT ON COLUMN keplersc.kdcomisquincena.c26 IS 'Utilidad bruta accesorios';
COMMENT ON COLUMN keplersc.kdcomisquincena.c25 IS 'Subsidio';
COMMENT ON COLUMN keplersc.kdcomisquincena.c24 IS 'Nota de descuento';
COMMENT ON COLUMN keplersc.kdcomisquincena.c23 IS 'Garantia extendida';
COMMENT ON COLUMN keplersc.kdcomisquincena.c22 IS 'Seguro';
COMMENT ON COLUMN keplersc.kdcomisquincena.c21 IS 'Gastos administrativos';
COMMENT ON COLUMN keplersc.kdcomisquincena.c20 IS 'Utilidad bruta';
COMMENT ON COLUMN keplersc.kdcomisquincena.c2 IS 'Anio';
COMMENT ON COLUMN keplersc.kdcomisquincena.c19 IS 'Asesor de TMKT';
COMMENT ON COLUMN keplersc.kdcomisquincena.c18 IS 'Edad de inventario';
COMMENT ON COLUMN keplersc.kdcomisquincena.c17 IS 'Traslado';
COMMENT ON COLUMN keplersc.kdcomisquincena.c16 IS 'Linea';
COMMENT ON COLUMN keplersc.kdcomisquincena.c15 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdcomisquincena.c14 IS 'Nuevo o Usado';
COMMENT ON COLUMN keplersc.kdcomisquincena.c13 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcomisquincena.c12 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdcomisquincena.c11 IS 'Tipo operario';
COMMENT ON COLUMN keplersc.kdcomisquincena.c10 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcomisquincena.c1 IS 'Sucursal';

