CREATE  TABLE keplersc.kdiv (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(5,2) NOT NULL DEFAULT 0,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 character varying(100) NOT NULL DEFAULT ''::character varying,
  c18 character varying(100) NOT NULL DEFAULT ''::character varying,
  c19 character varying(100) NOT NULL DEFAULT ''::character varying,
  c20 character varying(16) NOT NULL DEFAULT ''::character varying,
  c21 character varying(16) NOT NULL DEFAULT ''::character varying,
  c22 character varying(16) NOT NULL DEFAULT ''::character varying,
  c23 character varying(16) NOT NULL DEFAULT ''::character varying,
  c24 character varying(16) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c27 character varying(18) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(12) NOT NULL DEFAULT ''::character varying,
  c31 character varying(5) NOT NULL DEFAULT ''::character varying,
  c32 character varying(1) NOT NULL DEFAULT ''::character varying,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying,
  c35 character varying(1) NOT NULL DEFAULT ''::character varying,
  c36 character varying(1) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  c41 character varying(1) NOT NULL DEFAULT ''::character varying,
  c42 character varying(1) NOT NULL DEFAULT ''::character varying,
  c43 character varying(1) NOT NULL DEFAULT ''::character varying,
  c44 character varying(1) NOT NULL DEFAULT ''::character varying,
  c45 character varying(1) NOT NULL DEFAULT ''::character varying,
  c46 character varying(1) NOT NULL DEFAULT ''::character varying,
  c47 character varying(1) NOT NULL DEFAULT ''::character varying,
  c48 character varying(1) NOT NULL DEFAULT ''::character varying,
  c49 character varying(1) NOT NULL DEFAULT ''::character varying,
  c50 numeric NOT NULL DEFAULT 0,
  c51 numeric NOT NULL DEFAULT 0,
  c52 character varying(10) NOT NULL DEFAULT ''::character varying,
  c53 character varying(10) NOT NULL DEFAULT ''::character varying,
  c54 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdiv ADD CONSTRAINT pk_kdiv PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdiv02 ON keplersc.kdiv USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdiv03 ON keplersc.kdiv USING btree (c4, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdiv04 ON keplersc.kdiv USING btree (c5, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdiv05 ON keplersc.kdiv USING btree (c7, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdiv IS 'Catalogo vehiculos';
COMMENT ON COLUMN keplersc.kdiv.c8 IS 'Nuevo o Usado';
COMMENT ON COLUMN keplersc.kdiv.c7 IS 'Linea de Vehiculos';
COMMENT ON COLUMN keplersc.kdiv.c6 IS 'Tipo de Calculo';
COMMENT ON COLUMN keplersc.kdiv.c54 IS 'Numero de puertas';
COMMENT ON COLUMN keplersc.kdiv.c53 IS 'Combustible';
COMMENT ON COLUMN keplersc.kdiv.c52 IS 'Procedencia';
COMMENT ON COLUMN keplersc.kdiv.c51 IS 'Capacidad de ocupantes';
COMMENT ON COLUMN keplersc.kdiv.c50 IS 'Numero de cilindros';
COMMENT ON COLUMN keplersc.kdiv.c5 IS 'Clave de la marca';
COMMENT ON COLUMN keplersc.kdiv.c4 IS 'Clase (Automovil o Comercial)';
COMMENT ON COLUMN keplersc.kdiv.c31 IS 'Clave unidad de medida SAT';
COMMENT ON COLUMN keplersc.kdiv.c30 IS 'Clave de SAT';
COMMENT ON COLUMN keplersc.kdiv.c28 IS 'No usar regla de los 3 meses para este auto';
COMMENT ON COLUMN keplersc.kdiv.c27 IS 'Clave del producto que reemplaza';
COMMENT ON COLUMN keplersc.kdiv.c26 IS 'Fecha de inicio de la venta';
COMMENT ON COLUMN keplersc.kdiv.c24 IS 'Cuenta contable del IVA  a la Compra';
COMMENT ON COLUMN keplersc.kdiv.c23 IS 'Cuenta contable IVA de la venta';
COMMENT ON COLUMN keplersc.kdiv.c22 IS 'Cuenta contable precio de venta';
COMMENT ON COLUMN keplersc.kdiv.c21 IS 'Cuenta contable costo de venta';
COMMENT ON COLUMN keplersc.kdiv.c20 IS 'Cuenta contable de inventarios';
COMMENT ON COLUMN keplersc.kdiv.c2 IS 'Descripcion Vehiculo';
COMMENT ON COLUMN keplersc.kdiv.c19 IS 'Paquete 3';
COMMENT ON COLUMN keplersc.kdiv.c18 IS 'Paquete 2';
COMMENT ON COLUMN keplersc.kdiv.c17 IS 'Paquete 1';
COMMENT ON COLUMN keplersc.kdiv.c16 IS 'Clave del catalogo de la marca';
COMMENT ON COLUMN keplersc.kdiv.c14 IS 'Precio de lista del Vehiculo';
COMMENT ON COLUMN keplersc.kdiv.c11 IS 'Unidades todavia en produccion';
COMMENT ON COLUMN keplersc.kdiv.c10 IS 'Meses promedio para entrega';
COMMENT ON COLUMN keplersc.kdiv.c1 IS 'Clave del Vehiculo';

