CREATE  TABLE keplersc.kdesqgv (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,2) NOT NULL DEFAULT 0,
  c3 numeric(10,2) NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 numeric(10,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
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
  c22 numeric(10,2) NOT NULL DEFAULT 0,
  c23 numeric(10,2) NOT NULL DEFAULT 0,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdesqgv ADD CONSTRAINT pk_kdesqgv PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdesqgv IS 'bonos y descuentos de ventas';
COMMENT ON COLUMN keplersc.kdesqgv.c9 IS 'Descuento por Unidades Atrasadas en Nuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c8 IS 'Bono por Alcanzar Objetivo 2 de CSI';
COMMENT ON COLUMN keplersc.kdesqgv.c7 IS 'Bono por Alcanzar Objetivo 1 de CSI';
COMMENT ON COLUMN keplersc.kdesqgv.c6 IS 'Bono por Alcanzar Objetivo de % Share Financiera 2';
COMMENT ON COLUMN keplersc.kdesqgv.c5 IS 'Bono por Alcanzar Objetivo de % Share Financiera 1';
COMMENT ON COLUMN keplersc.kdesqgv.c4 IS 'Bono por Alcanzar Objetivo de MARGEN DE UTILIDAD';
COMMENT ON COLUMN keplersc.kdesqgv.c3 IS 'Bono x Alcanzar segundo objetivo de entregas Nuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c25 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdesqgv.c24 IS 'Pagar Flotillas';
COMMENT ON COLUMN keplersc.kdesqgv.c23 IS 'Bono x Alcanzar 2do Objetivo Financiera Seminuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c22 IS 'Bono x Alcanzar 1er Objetivo Financiera Seminuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c21 IS 'Bono x Alcanzar 2do objetivo de entregas SemiNuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c20 IS 'Bono x Alcanzar 1er objetivo de entregas SemiNuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c2 IS 'Bono x Alcanzar primer objetivo de entregas Nuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c19 IS 'Bono Facturacion de Seminuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c18 IS 'Bono Combinado de Seminuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c17 IS 'Bono por Alcance Objetivo de Seguros Contado';
COMMENT ON COLUMN keplersc.kdesqgv.c16 IS 'Bono por Alcance Objetivo Accesorios';
COMMENT ON COLUMN keplersc.kdesqgv.c15 IS 'Bono por Alcance de Entregas Trimestrales';
COMMENT ON COLUMN keplersc.kdesqgv.c14 IS 'Bono Objetivo de Venta de Garantia Extendida';
COMMENT ON COLUMN keplersc.kdesqgv.c13 IS 'Bono Objetivo de Tomas';
COMMENT ON COLUMN keplersc.kdesqgv.c12 IS 'Bono Objetivo de Facturacion de Nuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c11 IS 'Bono Combinado';
COMMENT ON COLUMN keplersc.kdesqgv.c10 IS 'Descuento por Unidades Atrasadas en Seminuevos';
COMMENT ON COLUMN keplersc.kdesqgv.c1 IS 'Esquema';

