CREATE  TABLE keplersc.kdgocompradet (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(60) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgocompradet ADD CONSTRAINT pk_kdgocompradet PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdgocompradet02 ON keplersc.kdgocompradet USING btree (c1, c12, c11, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdgocompradet IS 'Detalle de Ordenes de Compra';
COMMENT ON COLUMN keplersc.kdgocompradet.c9 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdgocompradet.c8 IS 'Clave del gastos';
COMMENT ON COLUMN keplersc.kdgocompradet.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdgocompradet.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdgocompradet.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdgocompradet.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgocompradet.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgocompradet.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdgocompradet.c12 IS 'Proveedor';
COMMENT ON COLUMN keplersc.kdgocompradet.c11 IS '0 Sin compra; 10 Comprado';
COMMENT ON COLUMN keplersc.kdgocompradet.c10 IS 'Monto';
COMMENT ON COLUMN keplersc.kdgocompradet.c1 IS 'Sucursal';

