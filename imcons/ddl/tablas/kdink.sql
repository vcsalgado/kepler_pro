CREATE  TABLE keplersc.kdink (
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
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdink ON keplersc.kdink USING btree (c1, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdink IS 'Resumen mensual movtos inventario';
COMMENT ON COLUMN keplersc.kdink.c63 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink.c62 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink.c61 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink.c60 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink.c59 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink.c58 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink.c57 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink.c56 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink.c55 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink.c54 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink.c53 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink.c52 IS 'Monto Salidas Enero';
COMMENT ON COLUMN keplersc.kdink.c51 IS 'Diciembvre';
COMMENT ON COLUMN keplersc.kdink.c50 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink.c49 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink.c48 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink.c47 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink.c46 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink.c45 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink.c44 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink.c43 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink.c42 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink.c41 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink.c40 IS 'Cantidad salidas Enero';
COMMENT ON COLUMN keplersc.kdink.c33 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink.c32 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink.c31 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink.c30 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdink.c29 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink.c28 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink.c27 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink.c26 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink.c25 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink.c24 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink.c23 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink.c22 IS 'Monto Entradas Enero';
COMMENT ON COLUMN keplersc.kdink.c21 IS 'Diciembre';
COMMENT ON COLUMN keplersc.kdink.c20 IS 'Noviembre';
COMMENT ON COLUMN keplersc.kdink.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdink.c19 IS 'Octubre';
COMMENT ON COLUMN keplersc.kdink.c18 IS 'Septiembre';
COMMENT ON COLUMN keplersc.kdink.c17 IS 'Agosto';
COMMENT ON COLUMN keplersc.kdink.c16 IS 'Julio';
COMMENT ON COLUMN keplersc.kdink.c15 IS 'Junio';
COMMENT ON COLUMN keplersc.kdink.c14 IS 'Mayo';
COMMENT ON COLUMN keplersc.kdink.c13 IS 'Abril';
COMMENT ON COLUMN keplersc.kdink.c12 IS 'Marzo';
COMMENT ON COLUMN keplersc.kdink.c11 IS 'Febrero';
COMMENT ON COLUMN keplersc.kdink.c10 IS 'Cantidad Entradas Enero';
COMMENT ON COLUMN keplersc.kdink.c1 IS 'Sucursal';

