CREATE  TABLE keplersc.kdm2 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(18) NOT NULL DEFAULT ''::character varying,
  c9 numeric(15,6) NOT NULL DEFAULT 0,
  c10 character varying(300) NOT NULL DEFAULT ''::character varying,
  c11 character varying(4) NOT NULL DEFAULT ''::character varying,
  c12 numeric(18,6) NOT NULL DEFAULT 0,
  c13 numeric(19,6) NOT NULL DEFAULT 0,
  c14 double precision NOT NULL DEFAULT 0,
  c15 double precision NOT NULL DEFAULT 0,
  c16 double precision NOT NULL DEFAULT 0,
  c17 character varying(4) NOT NULL DEFAULT ''::character varying,
  c18 character varying(4) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric NOT NULL DEFAULT 0,
  c21 numeric NOT NULL DEFAULT 0,
  c22 character varying(7) NOT NULL DEFAULT ''::character varying,
  c23 numeric NOT NULL DEFAULT 0,
  c24 double precision NOT NULL DEFAULT 0,
  c25 character varying(7) NOT NULL DEFAULT ''::character varying,
  c26 double precision NOT NULL DEFAULT 0,
  c27 character varying NOT NULL DEFAULT ''::character varying,
  c28 character varying(20) NOT NULL DEFAULT ''::character varying,
  c29 numeric NOT NULL DEFAULT 0,
  c30 numeric NOT NULL DEFAULT 0,
  c31 double precision NOT NULL DEFAULT 0,
  c32 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 numeric(15,2) NOT NULL DEFAULT 0,
  c35 numeric(15,2) NOT NULL DEFAULT 0,
  c36 character varying(5) NOT NULL DEFAULT ''::character varying,
  c37 numeric(15,2) NOT NULL DEFAULT 0,
  c38 numeric(15,2) NOT NULL DEFAULT 0,
  c39 character varying(10) NOT NULL DEFAULT ''::character varying,
  c40 character varying(10) NOT NULL DEFAULT ''::character varying,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm2 ON keplersc.kdm2 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdm202 ON keplersc.kdm2 USING btree (c1, c2, c3, c4, c8, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdm203 ON keplersc.kdm2 USING btree (c1, c2, c3, c4, c25, c8, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdm204 ON keplersc.kdm2 USING btree (c8, c32, c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm2 IS 'Partidas de Documentos';
COMMENT ON COLUMN keplersc.kdm2.c9 IS 'Cantidad unidades';
COMMENT ON COLUMN keplersc.kdm2.c8 IS 'Clave producto';
COMMENT ON COLUMN keplersc.kdm2.c7 IS 'Numero partida';
COMMENT ON COLUMN keplersc.kdm2.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm2.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm2.c40 IS 'Concepto';
COMMENT ON COLUMN keplersc.kdm2.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm2.c39 IS 'Orden de trabajo';
COMMENT ON COLUMN keplersc.kdm2.c38 IS 'Venta En moneda';
COMMENT ON COLUMN keplersc.kdm2.c37 IS 'Costo en moneda';
COMMENT ON COLUMN keplersc.kdm2.c36 IS 'Moneda';
COMMENT ON COLUMN keplersc.kdm2.c35 IS 'Existencia previa en pesos';
COMMENT ON COLUMN keplersc.kdm2.c34 IS 'Existencia previa en unidades';
COMMENT ON COLUMN keplersc.kdm2.c33 IS 'Monto del costo';
COMMENT ON COLUMN keplersc.kdm2.c32 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdm2.c31 IS 'Cantidad restada al documento anterior (concatenca)';
COMMENT ON COLUMN keplersc.kdm2.c30 IS 'Número de cargos (descuentos usados como cargos)';
COMMENT ON COLUMN keplersc.kdm2.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm2.c29 IS 'Clave del almacén o Referencia';
COMMENT ON COLUMN keplersc.kdm2.c28 IS 'Codigo reemplazado o Clave del Vendedor ó Comprador';
COMMENT ON COLUMN keplersc.kdm2.c27 IS 'Codigo requisicion';
COMMENT ON COLUMN keplersc.kdm2.c26 IS 'Costo venta partida';
COMMENT ON COLUMN keplersc.kdm2.c25 IS 'Clave cliente';
COMMENT ON COLUMN keplersc.kdm2.c24 IS 'Saldo unidades partida';
COMMENT ON COLUMN keplersc.kdm2.c23 IS 'Partida';
COMMENT ON COLUMN keplersc.kdm2.c22 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm2.c21 IS 'Tipo documento anterior';
COMMENT ON COLUMN keplersc.kdm2.c20 IS 'Grupo documento anterior';
COMMENT ON COLUMN keplersc.kdm2.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm2.c19 IS 'Naturaleza documento anterior';
COMMENT ON COLUMN keplersc.kdm2.c18 IS 'Porcentaje IEPS';
COMMENT ON COLUMN keplersc.kdm2.c17 IS 'Porcentaje IVA';
COMMENT ON COLUMN keplersc.kdm2.c16 IS 'Porcentaje descuento 3';
COMMENT ON COLUMN keplersc.kdm2.c15 IS 'Porcentaje descuento 2';
COMMENT ON COLUMN keplersc.kdm2.c14 IS 'Porcentaje descuento';
COMMENT ON COLUMN keplersc.kdm2.c13 IS 'Importe partida';
COMMENT ON COLUMN keplersc.kdm2.c12 IS 'Precio unitario producto';
COMMENT ON COLUMN keplersc.kdm2.c11 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdm2.c10 IS 'Descripcion producto';
COMMENT ON COLUMN keplersc.kdm2.c1 IS 'Clave sucursal';

