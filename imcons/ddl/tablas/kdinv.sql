CREATE  TABLE keplersc.kdinv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 character varying(60) NOT NULL DEFAULT ''::character varying,
  c5 character varying(3) NOT NULL DEFAULT ''::character varying,
  c6 character varying(3) NOT NULL DEFAULT ''::character varying,
  c7 character varying(4) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 character varying(5) NOT NULL DEFAULT ''::character varying,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 numeric NOT NULL DEFAULT 0,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinv ADD CONSTRAINT pk_kdinv PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdinv02 ON keplersc.kdinv USING btree (c1, c3, c12, c11, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinv03 ON keplersc.kdinv USING btree (c1, c3, c5, c6, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdinv.c9 IS 'Empresa donde se lozaliza';
COMMENT ON COLUMN keplersc.kdinv.c8 IS 'Serie';
COMMENT ON COLUMN keplersc.kdinv.c7 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdinv.c6 IS 'Vestiduras';
COMMENT ON COLUMN keplersc.kdinv.c5 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdinv.c4 IS 'Descripcion del vehiculo';
COMMENT ON COLUMN keplersc.kdinv.c3 IS 'Clave del vehiculo';
COMMENT ON COLUMN keplersc.kdinv.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdinv.c13 IS 'Nuevo/Usado';
COMMENT ON COLUMN keplersc.kdinv.c12 IS 'Prioridad de venta';
COMMENT ON COLUMN keplersc.kdinv.c11 IS 'Fecha de compra';
COMMENT ON COLUMN keplersc.kdinv.c10 IS 'Fecha de asignacion';
COMMENT ON COLUMN keplersc.kdinv.c1 IS 'Sucursal';

