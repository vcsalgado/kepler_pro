CREATE  TABLE keplersc.kdncred (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdncred ADD CONSTRAINT pk_kdncred PRIMARY KEY (c1, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdncred02 ON keplersc.kdncred USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdncred03 ON keplersc.kdncred USING btree (c1, c9, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdncred IS 'Notas de descuento';
COMMENT ON COLUMN keplersc.kdncred.c9 IS 'IVA';
COMMENT ON COLUMN keplersc.kdncred.c8 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdncred.c7 IS 'Folio';
COMMENT ON COLUMN keplersc.kdncred.c6 IS 'Tpo';
COMMENT ON COLUMN keplersc.kdncred.c5 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdncred.c4 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdncred.c3 IS 'Genero';
COMMENT ON COLUMN keplersc.kdncred.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdncred.c11 IS 'Fuera de la Operacion (   0 = Dentro del Ciclo Normal de la Operacion  10 = Fuera del Ciclo Normal de la Operacion)';
COMMENT ON COLUMN keplersc.kdncred.c10 IS 'Importe';
COMMENT ON COLUMN keplersc.kdncred.c1 IS 'Sucursal';

