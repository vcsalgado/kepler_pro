CREATE  TABLE keplersc.kdgocompra (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(7) NOT NULL DEFAULT ''::character varying,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgocompra ADD CONSTRAINT pk_kdgocompra PRIMARY KEY (c1, c2, c3, c4, c5, c6);
COMMENT ON TABLE keplersc.kdgocompra IS 'Orden de Compra';
COMMENT ON COLUMN keplersc.kdgocompra.c9 IS 'Importe';
COMMENT ON COLUMN keplersc.kdgocompra.c8 IS 'IVA';
COMMENT ON COLUMN keplersc.kdgocompra.c7 IS 'Proveedor';
COMMENT ON COLUMN keplersc.kdgocompra.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdgocompra.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdgocompra.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgocompra.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgocompra.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdgocompra.c1 IS 'Sucursal';

