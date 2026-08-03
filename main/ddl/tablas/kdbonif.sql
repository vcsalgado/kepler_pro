CREATE  TABLE keplersc.kdbonif (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdbonif ADD CONSTRAINT pk_kdbonif PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdbonif02 ON keplersc.kdbonif USING btree (c1, c8, c9, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdbonif.c9 IS 'Tipo de Bonificacion C = Compra V = Venta';
COMMENT ON COLUMN keplersc.kdbonif.c8 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdbonif.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdbonif.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdbonif.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdbonif.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdbonif.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdbonif.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdbonif.c10 IS 'Monto';
COMMENT ON COLUMN keplersc.kdbonif.c1 IS 'Sucursal';

