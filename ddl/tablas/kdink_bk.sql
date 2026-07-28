CREATE  TABLE keplersc.kdink_bk (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0,
  c12 numeric(10,2) NOT NULL DEFAULT 0,
  c13 numeric(10,2) NOT NULL DEFAULT 0,
  c14 numeric(10,2) NOT NULL DEFAULT 0,
  c15 numeric(10,2) NOT NULL DEFAULT 0,
  c16 numeric(10,2) NOT NULL DEFAULT 0,
  c17 numeric(10,2) NOT NULL DEFAULT 0,
  c18 numeric(10,2) NOT NULL DEFAULT 0,
  c19 numeric(10,2) NOT NULL DEFAULT 0,
  c20 numeric(10,2) NOT NULL DEFAULT 0,
  c21 numeric(10,2) NOT NULL DEFAULT 0,
  c22 numeric(15,2) NOT NULL DEFAULT 0,
  c23 numeric(15,2) NOT NULL DEFAULT 0,
  c24 numeric(15,2) NOT NULL DEFAULT 0,
  c25 numeric(15,2) NOT NULL DEFAULT 0,
  c26 numeric(15,2) NOT NULL DEFAULT 0,
  c27 numeric(15,2) NOT NULL DEFAULT 0,
  c28 numeric(15,2) NOT NULL DEFAULT 0,
  c29 numeric(15,2) NOT NULL DEFAULT 0,
  c30 numeric(15,2) NOT NULL DEFAULT 0,
  c31 numeric(15,2) NOT NULL DEFAULT 0,
  c32 numeric(15,2) NOT NULL DEFAULT 0,
  c33 numeric(15,2) NOT NULL DEFAULT 0,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying,
  c35 character varying(1) NOT NULL DEFAULT ''::character varying,
  c36 character varying(1) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 numeric(10,2) NOT NULL DEFAULT 0,
  c41 numeric(10,2) NOT NULL DEFAULT 0,
  c42 numeric(10,2) NOT NULL DEFAULT 0,
  c43 numeric(10,2) NOT NULL DEFAULT 0,
  c44 numeric(10,2) NOT NULL DEFAULT 0,
  c45 numeric(10,2) NOT NULL DEFAULT 0,
  c46 numeric(10,2) NOT NULL DEFAULT 0,
  c47 numeric(10,2) NOT NULL DEFAULT 0,
  c48 numeric(10,2) NOT NULL DEFAULT 0,
  c49 numeric(10,2) NOT NULL DEFAULT 0,
  c50 numeric(10,2) NOT NULL DEFAULT 0,
  c51 numeric(10,2) NOT NULL DEFAULT 0,
  c52 numeric(15,2) NOT NULL DEFAULT 0,
  c53 numeric(15,2) NOT NULL DEFAULT 0,
  c54 numeric(15,2) NOT NULL DEFAULT 0,
  c55 numeric(15,2) NOT NULL DEFAULT 0,
  c56 numeric(15,2) NOT NULL DEFAULT 0,
  c57 numeric(15,2) NOT NULL DEFAULT 0,
  c58 numeric(15,2) NOT NULL DEFAULT 0,
  c59 numeric(15,2) NOT NULL DEFAULT 0,
  c60 numeric(15,2) NOT NULL DEFAULT 0,
  c61 numeric(15,2) NOT NULL DEFAULT 0,
  c62 numeric(15,2) NOT NULL DEFAULT 0,
  c63 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdink_bk_c1_c2_c3_idx ON keplersc.kdink_bk USING btree (c1, c2, c3) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdink_bk.c63 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink_bk.c62 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink_bk.c61 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink_bk.c60 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink_bk.c59 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink_bk.c58 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink_bk.c57 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink_bk.c56 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink_bk.c55 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink_bk.c54 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink_bk.c53 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink_bk.c52 IS 'Monto Salidas Enero';
COMMENT ON COLUMN keplersc.kdink_bk.c51 IS 'Diciembvre';
COMMENT ON COLUMN keplersc.kdink_bk.c50 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink_bk.c49 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink_bk.c48 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink_bk.c47 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink_bk.c46 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink_bk.c45 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink_bk.c44 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink_bk.c43 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink_bk.c42 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink_bk.c41 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink_bk.c40 IS 'Cantidad salidas Enero';
COMMENT ON COLUMN keplersc.kdink_bk.c33 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink_bk.c32 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink_bk.c31 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink_bk.c30 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink_bk.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdink_bk.c29 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink_bk.c28 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink_bk.c27 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink_bk.c26 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink_bk.c25 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink_bk.c24 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink_bk.c23 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink_bk.c22 IS 'Monto Entradas Enero';
COMMENT ON COLUMN keplersc.kdink_bk.c21 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink_bk.c20 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink_bk.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdink_bk.c19 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink_bk.c18 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink_bk.c17 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink_bk.c16 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink_bk.c15 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink_bk.c14 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink_bk.c13 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink_bk.c12 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink_bk.c11 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink_bk.c10 IS 'Cantidad Entradas Enero';
COMMENT ON COLUMN keplersc.kdink_bk.c1 IS 'Sucursal';

