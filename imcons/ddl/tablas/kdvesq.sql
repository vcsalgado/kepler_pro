CREATE  TABLE keplersc.kdvesq (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 numeric(10,2) NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0,
  c5 numeric(10,2) NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric(10,5) NOT NULL DEFAULT 0,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric(10,2) NOT NULL DEFAULT 0,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(18) NOT NULL DEFAULT ''::character varying,
  c15 numeric(10,2) NOT NULL DEFAULT 0,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(1) NOT NULL DEFAULT ''::character varying,
  c25 numeric(10,2) NOT NULL DEFAULT 0,
  c26 numeric(10,2) NOT NULL DEFAULT 0,
  c27 numeric(10,2) NOT NULL DEFAULT 0,
  c28 numeric(10,2) NOT NULL DEFAULT 0,
  c29 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvesq ADD CONSTRAINT pk_kdvesq PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdvesq IS 'Esquema de Ventas';
COMMENT ON COLUMN keplersc.kdvesq.c8 IS 'Aumento por unidad de inventario';
COMMENT ON COLUMN keplersc.kdvesq.c7 IS 'Descuento por Traspaso';
COMMENT ON COLUMN keplersc.kdvesq.c5 IS 'Adicionales';
COMMENT ON COLUMN keplersc.kdvesq.c4 IS 'Adicionales';
COMMENT ON COLUMN keplersc.kdvesq.c3 IS 'Sueldo Base';
COMMENT ON COLUMN keplersc.kdvesq.c29 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdvesq.c28 IS 'Bono Semana 4';
COMMENT ON COLUMN keplersc.kdvesq.c27 IS 'Bono Semana 3';
COMMENT ON COLUMN keplersc.kdvesq.c26 IS 'Bono Semana 2';
COMMENT ON COLUMN keplersc.kdvesq.c25 IS 'Bono semana 1';
COMMENT ON COLUMN keplersc.kdvesq.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdvesq.c19 IS 'Activo';
COMMENT ON COLUMN keplersc.kdvesq.c15 IS 'Bono seminuevos cerificados';
COMMENT ON COLUMN keplersc.kdvesq.c14 IS 'Clave seminuevos certificados';
COMMENT ON COLUMN keplersc.kdvesq.c12 IS 'Bono por venta';
COMMENT ON COLUMN keplersc.kdvesq.c11 IS 'Dias para bono por ventas';
COMMENT ON COLUMN keplersc.kdvesq.c10 IS 'Bono por toma';
COMMENT ON COLUMN keplersc.kdvesq.c1 IS 'Esquema';

