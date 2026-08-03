CREATE  TABLE keplersc.kdasig (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 character varying(230) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(4) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdasig ADD CONSTRAINT pk_kdasig PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdasig02 ON keplersc.kdasig USING btree (c1, c11, c3, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdasig03 ON keplersc.kdasig USING btree (c1, c3, c5, c6, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdasig IS 'Autos Asignacion';
COMMENT ON COLUMN keplersc.kdasig.c9 IS 'Fecha de asignacion';
COMMENT ON COLUMN keplersc.kdasig.c8 IS 'Serie';
COMMENT ON COLUMN keplersc.kdasig.c7 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdasig.c6 IS 'Vestiduras';
COMMENT ON COLUMN keplersc.kdasig.c5 IS 'Color exterior';
COMMENT ON COLUMN keplersc.kdasig.c4 IS 'Descripcion del vehiculo';
COMMENT ON COLUMN keplersc.kdasig.c3 IS 'Clave del vehiculo';
COMMENT ON COLUMN keplersc.kdasig.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdasig.c11 IS 'Status 0 Cancelado, 10 Asignado, 20 Comprado';
COMMENT ON COLUMN keplersc.kdasig.c10 IS 'Nuevo / Usado';
COMMENT ON COLUMN keplersc.kdasig.c1 IS 'Sucursal';

