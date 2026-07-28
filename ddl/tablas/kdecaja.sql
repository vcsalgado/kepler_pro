CREATE  TABLE keplersc.kdecaja (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdecaja ADD CONSTRAINT pk_kdecaja PRIMARY KEY (c1, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdecaja02 ON keplersc.kdecaja USING btree (c1, c2, c9, c3, c4, c5, c6, c7, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdecaja03 ON keplersc.kdecaja USING btree (c1, c3, c4, c5, c6, c2, c9, c7, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdecaja IS 'Caja movimientos';
COMMENT ON COLUMN keplersc.kdecaja.c9 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdecaja.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdecaja.c7 IS 'Folio';
COMMENT ON COLUMN keplersc.kdecaja.c6 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdecaja.c5 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdecaja.c4 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdecaja.c3 IS 'Genero';
COMMENT ON COLUMN keplersc.kdecaja.c2 IS 'Ingreso / Egreso';
COMMENT ON COLUMN keplersc.kdecaja.c10 IS 'Monto';
COMMENT ON COLUMN keplersc.kdecaja.c1 IS 'Sucursal';

