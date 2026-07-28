CREATE  TABLE keplersc.kdcomismov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 character varying(20) NOT NULL DEFAULT ''::character varying,
  c13 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 numeric(15,2) NOT NULL DEFAULT 0,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(15,2) NOT NULL DEFAULT 0,
  c24 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c25 character varying(4) NOT NULL DEFAULT ''::character varying,
  c26 character varying(5) NOT NULL DEFAULT ''::character varying,
  c27 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomismov ADD CONSTRAINT pk_kdcomismov PRIMARY KEY (c1, c2, c3, c4, c5, c6, c10);
CREATE INDEX IF NOT EXISTS sindkdcomismov02 ON keplersc.kdcomismov USING btree (c1, c9, c11, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov03 ON keplersc.kdcomismov USING btree (c1, c8, c2, c3, c4, c5, c6, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov04 ON keplersc.kdcomismov USING btree (c1, c9, c12, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov05 ON keplersc.kdcomismov USING btree (c1, c9, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov06 ON keplersc.kdcomismov USING btree (c1, c12, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov07 ON keplersc.kdcomismov USING btree (c1, c11, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov08 ON keplersc.kdcomismov USING btree (c1, c26, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcomismov IS 'Vales de Salida';
COMMENT ON COLUMN keplersc.kdcomismov.c9 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdcomismov.c8 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdcomismov.c7 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcomismov.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdcomismov.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcomismov.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcomismov.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcomismov.c27 IS 'Complementos de Facturacion';
COMMENT ON COLUMN keplersc.kdcomismov.c26 IS 'Coach';
COMMENT ON COLUMN keplersc.kdcomismov.c25 IS 'Anio-Modelo';
COMMENT ON COLUMN keplersc.kdcomismov.c24 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcomismov.c23 IS 'Costo';
COMMENT ON COLUMN keplersc.kdcomismov.c22 IS 'Importe';
COMMENT ON COLUMN keplersc.kdcomismov.c21 IS 'IVA';
COMMENT ON COLUMN keplersc.kdcomismov.c20 IS 'ISAN';
COMMENT ON COLUMN keplersc.kdcomismov.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdcomismov.c19 IS 'Garantia Extendida';
COMMENT ON COLUMN keplersc.kdcomismov.c18 IS 'Accesorios';
COMMENT ON COLUMN keplersc.kdcomismov.c17 IS 'Seguro';
COMMENT ON COLUMN keplersc.kdcomismov.c16 IS 'Gastos Administrativos';
COMMENT ON COLUMN keplersc.kdcomismov.c15 IS 'Descuento';
COMMENT ON COLUMN keplersc.kdcomismov.c14 IS 'Tipo de auto (Demo, Nuevo, Usado)';
COMMENT ON COLUMN keplersc.kdcomismov.c13 IS 'Fecha de factura';
COMMENT ON COLUMN keplersc.kdcomismov.c12 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdcomismov.c11 IS 'Tipo de Operacion';
COMMENT ON COLUMN keplersc.kdcomismov.c10 IS 'Tipo 0 Alta; Tipo 1 Baja';
COMMENT ON COLUMN keplersc.kdcomismov.c1 IS 'Sucursal';
CREATE TRIGGER kdcomismov_notif AFTER INSERT OR DELETE OR UPDATE ON keplersc.kdcomismov FOR EACH ROW EXECUTE FUNCTION keplersc.notif_registrar_movto();

