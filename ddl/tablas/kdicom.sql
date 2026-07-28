CREATE  TABLE keplersc.kdicom (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(20) NOT NULL DEFAULT ''::character varying,
  c12 numeric NOT NULL DEFAULT 0,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(18) NOT NULL DEFAULT ''::character varying,
  c17 character varying(4) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(10) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
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
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(5) NOT NULL DEFAULT ''::character varying,
  c41 character varying(5) NOT NULL DEFAULT ''::character varying,
  c42 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdicom ADD CONSTRAINT pk_kdicom PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdicom02 ON keplersc.kdicom USING btree (c1, c16, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdicom03 ON keplersc.kdicom USING btree (c1, c4, c5, c6, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdicom04 ON keplersc.kdicom USING btree (c1, c40, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdicom05 ON keplersc.kdicom USING btree (c1, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdicom06 ON keplersc.kdicom USING btree (c1, c41, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdicom07 ON keplersc.kdicom USING btree (c1, c42, c9, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdicom IS 'Comisiones venta autos';
COMMENT ON COLUMN keplersc.kdicom.c9 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdicom.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdicom.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdicom.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdicom.c5 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdicom.c42 IS 'Valuador';
COMMENT ON COLUMN keplersc.kdicom.c41 IS 'Asesor Comprador';
COMMENT ON COLUMN keplersc.kdicom.c40 IS 'Comprador';
COMMENT ON COLUMN keplersc.kdicom.c4 IS 'Genero';
COMMENT ON COLUMN keplersc.kdicom.c39 IS 'Traspaso';
COMMENT ON COLUMN keplersc.kdicom.c37 IS 'Importe Final de la Compra';
COMMENT ON COLUMN keplersc.kdicom.c36 IS 'Otros conceptos posteriores al IVA';
COMMENT ON COLUMN keplersc.kdicom.c35 IS 'Otros conceptos posteriores al IVA';
COMMENT ON COLUMN keplersc.kdicom.c34 IS 'Otros conceptos posteriores al IVA';
COMMENT ON COLUMN keplersc.kdicom.c33 IS 'HoldBack';
COMMENT ON COLUMN keplersc.kdicom.c32 IS 'IVA de la Compra';
COMMENT ON COLUMN keplersc.kdicom.c31 IS 'Subtotal de la compra';
COMMENT ON COLUMN keplersc.kdicom.c30 IS 'Otros conceptos';
COMMENT ON COLUMN keplersc.kdicom.c3 IS 'Partida';
COMMENT ON COLUMN keplersc.kdicom.c29 IS 'Otros conceptos';
COMMENT ON COLUMN keplersc.kdicom.c28 IS 'Otros conceptos';
COMMENT ON COLUMN keplersc.kdicom.c27 IS 'Otros conceptos';
COMMENT ON COLUMN keplersc.kdicom.c26 IS 'Publicidad';
COMMENT ON COLUMN keplersc.kdicom.c25 IS 'Traslados';
COMMENT ON COLUMN keplersc.kdicom.c24 IS 'Cuotas y Suscriptores';
COMMENT ON COLUMN keplersc.kdicom.c23 IS 'Costo de la Unidad';
COMMENT ON COLUMN keplersc.kdicom.c20 IS 'Nuevo / Usado';
COMMENT ON COLUMN keplersc.kdicom.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdicom.c19 IS 'Linea';
COMMENT ON COLUMN keplersc.kdicom.c18 IS 'Marca';
COMMENT ON COLUMN keplersc.kdicom.c17 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdicom.c16 IS 'Clave del vehiculo';
COMMENT ON COLUMN keplersc.kdicom.c12 IS 'Status 0-Alta Compra 10-Baja Compra';
COMMENT ON COLUMN keplersc.kdicom.c11 IS 'Numero CDO';
COMMENT ON COLUMN keplersc.kdicom.c10 IS 'Proveedor';
COMMENT ON COLUMN keplersc.kdicom.c1 IS 'Sucursal';

