CREATE  TABLE keplersc.kdipva (
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
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(18) NOT NULL DEFAULT ''::character varying,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 character varying(7) NOT NULL DEFAULT ''::character varying,
  c17 character varying(5) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(4) NOT NULL DEFAULT ''::character varying,
  c21 character varying(10) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdipva ADD CONSTRAINT pk_kdipva PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdipva02 ON keplersc.kdipva USING btree (c1, c4, c5, c6, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdipva03 ON keplersc.kdipva USING btree (c1, c14, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdipva04 ON keplersc.kdipva USING btree (c1, c21, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdipva05 ON keplersc.kdipva USING btree (c1, c16, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdipva06 ON keplersc.kdipva USING btree (c1, c17, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdipva07 ON keplersc.kdipva USING btree (c1, c2, c9, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdipva IS 'Facturas pva';
COMMENT ON COLUMN keplersc.kdipva.c9 IS 'Fecha Factura';
COMMENT ON COLUMN keplersc.kdipva.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdipva.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdipva.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdipva.c5 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdipva.c4 IS 'Género Factura';
COMMENT ON COLUMN keplersc.kdipva.c32 IS 'Fuera de la operación';
COMMENT ON COLUMN keplersc.kdipva.c30 IS 'Importe';
COMMENT ON COLUMN keplersc.kdipva.c3 IS 'Partida';
COMMENT ON COLUMN keplersc.kdipva.c29 IS 'IVA';
COMMENT ON COLUMN keplersc.kdipva.c28 IS 'Cobranza';
COMMENT ON COLUMN keplersc.kdipva.c27 IS 'Intereses';
COMMENT ON COLUMN keplersc.kdipva.c26 IS 'Garantía Extendida';
COMMENT ON COLUMN keplersc.kdipva.c25 IS 'Accesorios';
COMMENT ON COLUMN keplersc.kdipva.c24 IS 'Gastos Administrativos';
COMMENT ON COLUMN keplersc.kdipva.c21 IS 'Línea';
COMMENT ON COLUMN keplersc.kdipva.c20 IS 'Año Modelo';
COMMENT ON COLUMN keplersc.kdipva.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdipva.c19 IS 'Nuevo / Usado';
COMMENT ON COLUMN keplersc.kdipva.c18 IS 'Marca';
COMMENT ON COLUMN keplersc.kdipva.c17 IS 'Tipo de Operación';
COMMENT ON COLUMN keplersc.kdipva.c16 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdipva.c15 IS 'Empresa';
COMMENT ON COLUMN keplersc.kdipva.c14 IS 'Clave del Vehículo';
COMMENT ON COLUMN keplersc.kdipva.c11 IS 'Clave del cliente';
COMMENT ON COLUMN keplersc.kdipva.c10 IS 'Status 0 =Alta 10 = Baja';
COMMENT ON COLUMN keplersc.kdipva.c1 IS 'Sucursal';

