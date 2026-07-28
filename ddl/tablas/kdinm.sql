CREATE  TABLE keplersc.kdinm (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(9) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinm ADD CONSTRAINT pk_kdinm PRIMARY KEY (c1, c5, c6, c7, c8, c9, c10, c13);
CREATE INDEX IF NOT EXISTS sindkdinm02 ON keplersc.kdinm USING btree (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinm03 ON keplersc.kdinm USING btree (c1, c3, c2, c5, c6, c7, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinm04 ON keplersc.kdinm USING btree (c1, c5, c6, c7, c8, c9, c10, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdinm05 ON keplersc.kdinm USING btree (c1, c6, c3, c2, c5, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinm IS 'Detalle movimientos de inventario';
COMMENT ON COLUMN keplersc.kdinm.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdinm.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdinm.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdinm.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdinm.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdinm.c4 IS 'Horas Minutos Segundos';
COMMENT ON COLUMN keplersc.kdinm.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdinm.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdinm.c13 IS '1=Alta o 0=Baja';
COMMENT ON COLUMN keplersc.kdinm.c12 IS 'Monto';
COMMENT ON COLUMN keplersc.kdinm.c11 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdinm.c10 IS 'Partida';
COMMENT ON COLUMN keplersc.kdinm.c1 IS 'Sucursal';

