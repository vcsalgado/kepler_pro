CREATE  TABLE keplersc.kdm3 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(30) NOT NULL DEFAULT ''::character varying,
  c10 character varying(18) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 character varying(7) NOT NULL DEFAULT ''::character varying,
  c13 double precision NOT NULL DEFAULT 0,
  c14 character varying(7) NOT NULL DEFAULT ''::character varying,
  c15 character varying(7) NOT NULL DEFAULT ''::character varying,
  c16 character varying(7) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 numeric NOT NULL DEFAULT 0,
  c22 numeric NOT NULL DEFAULT 0,
  c23 character varying(7) NOT NULL DEFAULT ''::character varying,
  c24 numeric NOT NULL DEFAULT 0,
  c25 numeric NOT NULL DEFAULT 0,
  c26 double precision NOT NULL DEFAULT 0,
  c27 double precision NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm3 ON keplersc.kdm3 USING btree (c1, c2, c3, c4, c5, c6, c7, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm3 IS 'Control Auxiliar por partida';
COMMENT ON COLUMN keplersc.kdm3.c9 IS 'Numero de serie o lote';
COMMENT ON COLUMN keplersc.kdm3.c8 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdm3.c7 IS 'No. Partida';
COMMENT ON COLUMN keplersc.kdm3.c6 IS 'Folio documento';
COMMENT ON COLUMN keplersc.kdm3.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm3.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm3.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm3.c27 IS 'No de unidades deducidas al documento anterior';
COMMENT ON COLUMN keplersc.kdm3.c26 IS 'Saldo en unidades del consecutivo';
COMMENT ON COLUMN keplersc.kdm3.c25 IS 'Consecutivo de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c24 IS 'Partida de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c23 IS 'Folio de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c22 IS 'Tipo de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c21 IS 'Grupo de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c20 IS 'Naturaleza de docto anterior';
COMMENT ON COLUMN keplersc.kdm3.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm3.c18 IS 'TMC cmp 5';
COMMENT ON COLUMN keplersc.kdm3.c17 IS 'TMC cmp 4';
COMMENT ON COLUMN keplersc.kdm3.c16 IS 'Color';
COMMENT ON COLUMN keplersc.kdm3.c15 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdm3.c14 IS 'Talla';
COMMENT ON COLUMN keplersc.kdm3.c13 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdm3.c12 IS 'Ubicación';
COMMENT ON COLUMN keplersc.kdm3.c11 IS 'Almacén';
COMMENT ON COLUMN keplersc.kdm3.c10 IS 'Pedimento';
COMMENT ON COLUMN keplersc.kdm3.c1 IS 'Sucursal';

