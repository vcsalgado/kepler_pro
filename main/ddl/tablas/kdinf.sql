CREATE  TABLE keplersc.kdinf (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 character varying(205) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying,
  c14 character varying(10) NOT NULL DEFAULT ''::character varying,
  c15 character varying(4) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(5) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(5) NOT NULL DEFAULT ''::character varying,
  c20 character varying(5) NOT NULL DEFAULT ''::character varying,
  c21 character varying(10) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(5) NOT NULL DEFAULT ''::character varying,
  c24 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 character varying(20) NOT NULL DEFAULT ''::character varying,
  c27 timestamp without time zone NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c28 character varying(40) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 numeric NOT NULL DEFAULT 0,
  c32 numeric NOT NULL DEFAULT 0,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(50) NOT NULL DEFAULT ''::character varying,
  c35 character varying(50) NOT NULL DEFAULT ''::character varying,
  c36 character varying(1) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(60) NOT NULL DEFAULT ''::character varying,
  c41 character varying(60) NOT NULL DEFAULT ''::character varying,
  c42 character varying(60) NOT NULL DEFAULT ''::character varying,
  c43 character varying(60) NOT NULL DEFAULT ''::character varying,
  c44 character varying(60) NOT NULL DEFAULT ''::character varying,
  c45 character varying(60) NOT NULL DEFAULT ''::character varying,
  c46 character varying(60) NOT NULL DEFAULT ''::character varying,
  c47 character varying(60) NOT NULL DEFAULT ''::character varying,
  c48 character varying(60) NOT NULL DEFAULT ''::character varying,
  c49 character varying(60) NOT NULL DEFAULT ''::character varying,
  c50 character varying(60) NOT NULL DEFAULT ''::character varying,
  c51 character varying(60) NOT NULL DEFAULT ''::character varying,
  c52 character varying(60) NOT NULL DEFAULT ''::character varying,
  c53 character varying(60) NOT NULL DEFAULT ''::character varying,
  c54 character varying(60) NOT NULL DEFAULT ''::character varying,
  c55 character varying(60) NOT NULL DEFAULT ''::character varying,
  c56 character varying(60) NOT NULL DEFAULT ''::character varying,
  c57 character varying(60) NOT NULL DEFAULT ''::character varying,
  c58 character varying(60) NOT NULL DEFAULT ''::character varying,
  c59 character varying(60) NOT NULL DEFAULT ''::character varying,
  c60 character varying(60) NOT NULL DEFAULT ''::character varying,
  c61 character varying(1) NOT NULL DEFAULT ''::character varying,
  c62 character varying(1) NOT NULL DEFAULT ''::character varying,
  c63 character varying(1) NOT NULL DEFAULT ''::character varying,
  c64 character varying(1) NOT NULL DEFAULT ''::character varying,
  c65 character varying(1) NOT NULL DEFAULT ''::character varying,
  c66 character varying(1) NOT NULL DEFAULT ''::character varying,
  c67 character varying(1) NOT NULL DEFAULT ''::character varying,
  c68 character varying(1) NOT NULL DEFAULT ''::character varying,
  c69 character varying(1) NOT NULL DEFAULT ''::character varying,
  c70 character varying(1) NOT NULL DEFAULT ''::character varying,
  c71 character varying(1) NOT NULL DEFAULT ''::character varying,
  c72 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c73 numeric(15,2) NOT NULL DEFAULT 0,
  c74 numeric(15,5) NOT NULL DEFAULT 0,
  c75 numeric NOT NULL DEFAULT 0,
  c76 character varying(1) NOT NULL DEFAULT ''::character varying,
  c77 numeric(15,5) NOT NULL DEFAULT 0,
  c78 character varying(1) NOT NULL DEFAULT ''::character varying,
  c79 character varying(1) NOT NULL DEFAULT ''::character varying,
  c80 character varying(50) NOT NULL DEFAULT ''::character varying,
  c81 character varying(50) NOT NULL DEFAULT ''::character varying,
  c82 character varying(50) NOT NULL DEFAULT ''::character varying,
  c83 character varying(50) NOT NULL DEFAULT ''::character varying,
  c84 character varying(22) NOT NULL DEFAULT ''::character varying,
  c85 character varying(50) NULL DEFAULT ''::character varying,
  c86 character varying(50) NULL DEFAULT ''::character varying,
  c87 character varying(4) NULL DEFAULT ''::character varying,
  c88 character varying(100) NULL DEFAULT ''::character varying,
  c89 character varying(20) NULL DEFAULT ''::character varying,
  c90 character varying(10) NOT NULL DEFAULT ''::character varying,
  c91 numeric NOT NULL DEFAULT 4,
  c92 numeric NOT NULL DEFAULT 4,
  c93 numeric NOT NULL DEFAULT 4,
  c94 character varying(10) NOT NULL DEFAULT 'GASOLINA'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinf ADD CONSTRAINT pk_kdinf PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdinf02 ON keplersc.kdinf USING btree (c1, c7, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf03 ON keplersc.kdinf USING btree (c1, c31, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf04 ON keplersc.kdinf USING btree (c1, c32, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf05 ON keplersc.kdinf USING btree (c1, c31, c32, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf06 ON keplersc.kdinf USING btree (c1, c19, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf07 ON keplersc.kdinf USING btree (c1, c5, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf08 ON keplersc.kdinf USING btree (c1, c3, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinf0vus2 ON keplersc.kdinf USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinfvus03 ON keplersc.kdinf USING btree (c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinfvus04 ON keplersc.kdinf USING btree (c1, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinfvus05 ON keplersc.kdinf USING btree (c5) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinf IS 'Registro de autos nuevos adquiridos (nuevos y seminuevos)';
COMMENT ON COLUMN keplersc.kdinf.c94 IS 'Combustible';
COMMENT ON COLUMN keplersc.kdinf.c93 IS 'Numero Puertas';
COMMENT ON COLUMN keplersc.kdinf.c92 IS 'Numero Cilindros';
COMMENT ON COLUMN keplersc.kdinf.c91 IS 'Capacidad Ocupantes';
COMMENT ON COLUMN keplersc.kdinf.c90 IS 'Procedencia';
COMMENT ON COLUMN keplersc.kdinf.c9 IS 'Numero inventario anterior';
COMMENT ON COLUMN keplersc.kdinf.c89 IS 'serie o vin usado';
COMMENT ON COLUMN keplersc.kdinf.c88 IS 'version usado';
COMMENT ON COLUMN keplersc.kdinf.c87 IS 'anio usado';
COMMENT ON COLUMN keplersc.kdinf.c86 IS 'modelo usado';
COMMENT ON COLUMN keplersc.kdinf.c85 IS 'marca usado';
COMMENT ON COLUMN keplersc.kdinf.c84 IS 'RFC';
COMMENT ON COLUMN keplersc.kdinf.c83 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdinf.c82 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdinf.c81 IS 'Direccion';
COMMENT ON COLUMN keplersc.kdinf.c80 IS 'Nombre aval';
COMMENT ON COLUMN keplersc.kdinf.c8 IS 'Numero transmision';
COMMENT ON COLUMN keplersc.kdinf.c78 IS 'Doctos generados';
COMMENT ON COLUMN keplersc.kdinf.c77 IS 'Porcentaje cobranza';
COMMENT ON COLUMN keplersc.kdinf.c76 IS 'Amortizacion variable';
COMMENT ON COLUMN keplersc.kdinf.c75 IS 'Plazo';
COMMENT ON COLUMN keplersc.kdinf.c74 IS 'porcentaje interes';
COMMENT ON COLUMN keplersc.kdinf.c73 IS 'Monto financiar';
COMMENT ON COLUMN keplersc.kdinf.c72 IS 'Fecha inicio tabla';
COMMENT ON COLUMN keplersc.kdinf.c7 IS 'Ultimos 8 digitos serie';
COMMENT ON COLUMN keplersc.kdinf.c60 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c6 IS 'Motor';
COMMENT ON COLUMN keplersc.kdinf.c59 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c58 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c57 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c56 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c55 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c54 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c53 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c52 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c51 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c50 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c5 IS 'Serie';
COMMENT ON COLUMN keplersc.kdinf.c49 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c48 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c47 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c46 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c45 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c44 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c43 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c42 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c41 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c40 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdinf.c4 IS 'Descripción del Vehiculo';
COMMENT ON COLUMN keplersc.kdinf.c35 IS 'Desc. color interior';
COMMENT ON COLUMN keplersc.kdinf.c34 IS 'Desc. color exterior';
COMMENT ON COLUMN keplersc.kdinf.c32 IS 'Estado venta
(10 Pedido Registrado, 20 Factura del Automovil Registrada, 30 Factura de PVA Registrada,
40 Documentos Registrados, 50 Nota de Descuento Registrada, 60 Vale de Salida Registrado, 70 Traspaso a Otra agencia Registrado)';
COMMENT ON COLUMN keplersc.kdinf.c31 IS 'Estado compra
(0 Inventario Cancelado, 10 Asignado a Planta, 20 Factura de Compra Registrada)';
COMMENT ON COLUMN keplersc.kdinf.c3 IS 'Clave del Vehiculo';
COMMENT ON COLUMN keplersc.kdinf.c28 IS 'Lugar pedimento';
COMMENT ON COLUMN keplersc.kdinf.c27 IS 'Fecha pedimento';
COMMENT ON COLUMN keplersc.kdinf.c26 IS 'Pedimento';
COMMENT ON COLUMN keplersc.kdinf.c24 IS 'Fecha asignación';
COMMENT ON COLUMN keplersc.kdinf.c23 IS 'Empresa lozalizacion';
COMMENT ON COLUMN keplersc.kdinf.c22 IS 'Es Demo 1=Si, Vacio = No, default es vacio';
COMMENT ON COLUMN keplersc.kdinf.c21 IS 'Nuevo / Usado';
COMMENT ON COLUMN keplersc.kdinf.c20 IS 'Clave calculo ISAN';
COMMENT ON COLUMN keplersc.kdinf.c2 IS 'Numero de Inventario';
COMMENT ON COLUMN keplersc.kdinf.c19 IS 'Clave inventario';
COMMENT ON COLUMN keplersc.kdinf.c18 IS 'Clase';
COMMENT ON COLUMN keplersc.kdinf.c17 IS 'Marca';
COMMENT ON COLUMN keplersc.kdinf.c15 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdinf.c14 IS 'RFV Registro Federal Vehiculos';
COMMENT ON COLUMN keplersc.kdinf.c13 IS 'Clave vehicular';
COMMENT ON COLUMN keplersc.kdinf.c12 IS 'Existe eje trasero?';
COMMENT ON COLUMN keplersc.kdinf.c11 IS 'Vestiduras';
COMMENT ON COLUMN keplersc.kdinf.c10 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdinf.c1 IS 'Sucursal';

