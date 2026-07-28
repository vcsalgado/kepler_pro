CREATE  TABLE keplersc.kdc20705 (
  c1 numeric NOT NULL DEFAULT 0,
  c2 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 character varying(40) NOT NULL DEFAULT ''::character varying,
  c7 character varying(40) NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 numeric(15,4) NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying,
  c14 character varying(7) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 numeric NOT NULL DEFAULT 0,
  c18 numeric NOT NULL DEFAULT 0,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(10) NOT NULL DEFAULT ''::character varying,
  c21 character varying(10) NOT NULL DEFAULT ''::character varying,
  c22 character varying(7) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 character varying(1) NOT NULL DEFAULT ''::character varying,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(20) NOT NULL DEFAULT ''::character varying,
  c31 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c32 character varying(20) NOT NULL DEFAULT ''::character varying,
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
  c50 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdc20705 ADD CONSTRAINT pk_kdc20705 PRIMARY KEY (c3, c2, c8, c1, c10);
CREATE INDEX IF NOT EXISTS kdc20705_c13_c2_c3_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c13, c2, c3, c8, c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdc20705_c14_c15_c16_c17_c18_c19_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c14, c15, c16, c17, c18, c19, c8, c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdc20705_c21_c2_c3_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c21, c2, c3, c8, c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdc20705_c2_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c2, c8, c1, c10) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdc20705_c3_c2_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c3, c2, c8, c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdc20705_c8_c1_c10_idx ON keplersc.kdc20705 USING btree (c8, c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdc2070505 ON keplersc.kdc20705 USING btree (c14, c15, c16, c17, c18, c19, c8, c1, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdc20705.c9 IS 'Monto en moneda de origen';
COMMENT ON COLUMN keplersc.kdc20705.c8 IS 'Tipo de póliza';
COMMENT ON COLUMN keplersc.kdc20705.c7 IS 'Referencia';
COMMENT ON COLUMN keplersc.kdc20705.c6 IS 'Descripción de la póliza';
COMMENT ON COLUMN keplersc.kdc20705.c50 IS 'Graba para IETU';
COMMENT ON COLUMN keplersc.kdc20705.c5 IS 'Monto';
COMMENT ON COLUMN keplersc.kdc20705.c4 IS 'C=cargo A=abono';
COMMENT ON COLUMN keplersc.kdc20705.c32 IS 'Hora de ultima modificacion';
COMMENT ON COLUMN keplersc.kdc20705.c31 IS 'Fecha de ultima modificacion';
COMMENT ON COLUMN keplersc.kdc20705.c30 IS 'Ultimo usuario que modifico la poliza';
COMMENT ON COLUMN keplersc.kdc20705.c3 IS 'Número de cuenta';
COMMENT ON COLUMN keplersc.kdc20705.c22 IS 'Referencia para conciliación bancaria (cta cheques)';
COMMENT ON COLUMN keplersc.kdc20705.c21 IS 'Clave del proyecto';
COMMENT ON COLUMN keplersc.kdc20705.c20 IS 'Clave del concepto';
COMMENT ON COLUMN keplersc.kdc20705.c2 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdc20705.c19 IS 'Folio';
COMMENT ON COLUMN keplersc.kdc20705.c18 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdc20705.c17 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdc20705.c16 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdc20705.c15 IS 'Género';
COMMENT ON COLUMN keplersc.kdc20705.c14 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdc20705.c11 IS 'Clave del departamento';
COMMENT ON COLUMN keplersc.kdc20705.c10 IS 'Número consecutivo de partida';
COMMENT ON COLUMN keplersc.kdc20705.c1 IS 'Número de póliza';
CREATE TRIGGER kdc20705_upd_nivel_after_crud AFTER INSERT OR DELETE OR UPDATE ON keplersc.kdc20705 FOR EACH ROW EXECUTE FUNCTION keplersc.cont_upd_saldos();

