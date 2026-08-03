CREATE  TABLE keplersc.kdgcompradet (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgcompradet ADD CONSTRAINT pk_kdgcompradet PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdgcompradet02 ON keplersc.kdgcompradet USING btree (c1, c8, c9, c10, c11, c12, c13, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdgcompradet.c9 IS 'Naturaleza Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c8 IS 'Genero Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdgcompradet.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdgcompradet.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdgcompradet.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgcompradet.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgcompradet.c2 IS 'Genero Compra';
COMMENT ON COLUMN keplersc.kdgcompradet.c13 IS 'Partida Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c12 IS 'Folio Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c11 IS 'Tipo Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c10 IS 'Grupo Ocompra';
COMMENT ON COLUMN keplersc.kdgcompradet.c1 IS 'Sucursal';

