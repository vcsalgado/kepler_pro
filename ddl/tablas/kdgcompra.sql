CREATE  TABLE keplersc.kdgcompra (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 character varying(7) NOT NULL DEFAULT ''::character varying,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0,
  c12 numeric(10,2) NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgcompra ADD CONSTRAINT pk_kdgcompra PRIMARY KEY (c1, c2, c3, c4, c5, c6);
CREATE INDEX IF NOT EXISTS sindkdgcompra02 ON keplersc.kdgcompra USING btree (c1, c8, c7) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdgcompra.c9 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgcompra.c8 IS 'Genero OCompra';
COMMENT ON COLUMN keplersc.kdgcompra.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdgcompra.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdgcompra.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdgcompra.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgcompra.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgcompra.c2 IS 'Genero Compra';
COMMENT ON COLUMN keplersc.kdgcompra.c13 IS 'Partida';
COMMENT ON COLUMN keplersc.kdgcompra.c12 IS 'Folio';
COMMENT ON COLUMN keplersc.kdgcompra.c11 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdgcompra.c10 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgcompra.c1 IS 'Sucursal';

