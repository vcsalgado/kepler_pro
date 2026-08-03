CREATE  TABLE keplersc.kdcomisadis (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomisadis ADD CONSTRAINT pk_kdcomisadis PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
COMMENT ON COLUMN keplersc.kdcomisadis.c9 IS 'Cargos de Bonificaciones';
COMMENT ON COLUMN keplersc.kdcomisadis.c8 IS 'Subsidio';
COMMENT ON COLUMN keplersc.kdcomisadis.c7 IS '0 = Alta 1 = Baja';
COMMENT ON COLUMN keplersc.kdcomisadis.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdcomisadis.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcomisadis.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcomisadis.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcomisadis.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdcomisadis.c14 IS 'Abono al Costo de Unidades';
COMMENT ON COLUMN keplersc.kdcomisadis.c13 IS 'Cargo al costo de Unidades';
COMMENT ON COLUMN keplersc.kdcomisadis.c12 IS 'Abono al Costo de Accesorios';
COMMENT ON COLUMN keplersc.kdcomisadis.c11 IS 'Cargo al Costo de Accesorios';
COMMENT ON COLUMN keplersc.kdcomisadis.c10 IS 'Abonos de Bonificaciones';
COMMENT ON COLUMN keplersc.kdcomisadis.c1 IS 'Sucursal';

