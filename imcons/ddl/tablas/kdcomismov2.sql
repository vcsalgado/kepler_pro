CREATE  TABLE keplersc.kdcomismov2 (
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
  c12 character varying(7) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying,
  c14 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c15 character varying(7) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomismov2 ADD CONSTRAINT pk_kdcomismov2 PRIMARY KEY (c1, c2, c3, c4, c5, c6, c10);
CREATE INDEX IF NOT EXISTS sindkdcomismov202 ON keplersc.kdcomismov2 USING btree (c1, c9, c11, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov203 ON keplersc.kdcomismov2 USING btree (c1, c8, c2, c3, c4, c5, c6, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov204 ON keplersc.kdcomismov2 USING btree (c1, c12, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov205 ON keplersc.kdcomismov2 USING btree (c1, c13, c7, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov206 ON keplersc.kdcomismov2 USING btree (c1, c15, c11, c14, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov207 ON keplersc.kdcomismov2 USING btree (c1, c16, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcomismov208 ON keplersc.kdcomismov2 USING btree (c1, c12, c14, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdcomismov2.c9 IS 'Asesor de Telemarketing';
COMMENT ON COLUMN keplersc.kdcomismov2.c8 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdcomismov2.c7 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdcomismov2.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdcomismov2.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcomismov2.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcomismov2.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcomismov2.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdcomismov2.c16 IS 'Comisión Pagada';
COMMENT ON COLUMN keplersc.kdcomismov2.c15 IS 'Asesor de la Venta';
COMMENT ON COLUMN keplersc.kdcomismov2.c14 IS 'FEcha para pago de Comisión';
COMMENT ON COLUMN keplersc.kdcomismov2.c13 IS 'Valuador';
COMMENT ON COLUMN keplersc.kdcomismov2.c12 IS 'Asesor de Toma de Seminuevo';
COMMENT ON COLUMN keplersc.kdcomismov2.c11 IS 'Tipo de Operacion';
COMMENT ON COLUMN keplersc.kdcomismov2.c10 IS 'Tipo 0 Alta 1 Baja';
COMMENT ON COLUMN keplersc.kdcomismov2.c1 IS 'Sucursal';

