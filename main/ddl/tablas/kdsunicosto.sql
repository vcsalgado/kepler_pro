CREATE  TABLE keplersc.kdsunicosto (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(7) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  st_x_comprobar character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsunicosto ADD CONSTRAINT pk_kdsunicosto PRIMARY KEY (c1, c2, c3, c4, c5, c6, c11, st_x_comprobar);
CREATE INDEX IF NOT EXISTS sindkdsunicosto02 ON keplersc.kdsunicosto USING btree (c7, c8, c1, c2, c3, c4, c5, c6, c11) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdsunicosto.st_x_comprobar IS 'ST x Comprobar [X] Comprobado : Reg Originado x Comprobacion de CxP ( Modulo Gastos )';
COMMENT ON COLUMN keplersc.kdsunicosto.c9 IS 'Tipo Costo';
COMMENT ON COLUMN keplersc.kdsunicosto.c8 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdsunicosto.c7 IS 'Sucursal del inventario';
COMMENT ON COLUMN keplersc.kdsunicosto.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdsunicosto.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdsunicosto.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdsunicosto.c3 IS 'Naturtaleza';
COMMENT ON COLUMN keplersc.kdsunicosto.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdsunicosto.c11 IS 'Partida';
COMMENT ON COLUMN keplersc.kdsunicosto.c10 IS 'Costo';
COMMENT ON COLUMN keplersc.kdsunicosto.c1 IS 'Sucursal';

