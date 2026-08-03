CREATE  TABLE keplersc.kdobjgv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric(5,2) NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric(5,2) NOT NULL DEFAULT 0,
  c11 numeric(5,2) NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric NOT NULL DEFAULT 0,
  c17 numeric(10,2) NOT NULL DEFAULT 0,
  c18 numeric(10,2) NOT NULL DEFAULT 0,
  c19 numeric(5,2) NOT NULL DEFAULT 0,
  c20 numeric(5,2) NOT NULL DEFAULT 0,
  c21 numeric NOT NULL DEFAULT 0,
  c22 numeric NOT NULL DEFAULT 0,
  c23 numeric NOT NULL DEFAULT 0,
  c24 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdobjgv ADD CONSTRAINT pk_kdobjgv PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON TABLE keplersc.kdobjgv IS 'Objetivos mensuales ventas para coaches';
COMMENT ON COLUMN keplersc.kdobjgv.c9 IS 'Objetivo Entregas Financiera 2 Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c8 IS 'Objetivo Entregas Financiera 1 Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c7 IS 'Objetivo Margen de Utilidad';
COMMENT ON COLUMN keplersc.kdobjgv.c6 IS '2do Objetivo de Entregas Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c5 IS '1er Objetivo de Entregas Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c4 IS 'Año';
COMMENT ON COLUMN keplersc.kdobjgv.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdobjgv.c24 IS 'Objetivo Entregas Financiera 1 SemiNuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c23 IS 'Objetivo Entregas Financiera 1 SemiNuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c22 IS 'Objetivo Entregas Financiera 2 SemiNuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c21 IS 'Objetivo Entregas Financiera 1 SemiNuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c20 IS 'Objetivo Facturacion de Seminuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c2 IS 'Coach';
COMMENT ON COLUMN keplersc.kdobjgv.c19 IS 'Libre';
COMMENT ON COLUMN keplersc.kdobjgv.c18 IS 'Objetivo Seguros Contado';
COMMENT ON COLUMN keplersc.kdobjgv.c17 IS 'Objetivo de U Bruta de Accesorios';
COMMENT ON COLUMN keplersc.kdobjgv.c16 IS 'Objetivo de Entregas con Garantia Extendida';
COMMENT ON COLUMN keplersc.kdobjgv.c15 IS 'Objetivo de Toma de Autos Seminuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c14 IS 'Objetivo de Facturacion Autos Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c13 IS 'Objetivo de Dias de Atraso Maximo Autos SemiNuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c12 IS 'Objetivo de Dias de Atraso Maximo Autos Nuevos';
COMMENT ON COLUMN keplersc.kdobjgv.c11 IS 'Objetivo 2 CSI';
COMMENT ON COLUMN keplersc.kdobjgv.c10 IS 'Objetivo 1 CSI';
COMMENT ON COLUMN keplersc.kdobjgv.c1 IS 'Sucursal';

