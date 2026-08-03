CREATE  TABLE keplersc.kdegastos (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdegastos ADD CONSTRAINT pk_kdegastos PRIMARY KEY (c1, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdegastos02 ON keplersc.kdegastos USING btree (c1, c2, c9, c3, c4, c5, c6, c7, c8) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdegastos.c9 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdegastos.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdegastos.c7 IS 'Folio';
COMMENT ON COLUMN keplersc.kdegastos.c6 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdegastos.c5 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdegastos.c4 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdegastos.c3 IS 'Genero';
COMMENT ON COLUMN keplersc.kdegastos.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kdegastos.c11 IS 'Monto';
COMMENT ON COLUMN keplersc.kdegastos.c10 IS 'Cargo o Abono';
COMMENT ON COLUMN keplersc.kdegastos.c1 IS 'Sucursal';

