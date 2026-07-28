CREATE  TABLE keplersc.kdxd (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 character varying(90) NOT NULL DEFAULT ''::character varying,
  c4 character varying(70) NOT NULL DEFAULT ''::character varying,
  c5 character varying(70) NOT NULL DEFAULT ''::character varying,
  c6 character varying(70) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(20) NOT NULL DEFAULT ''::character varying,
  c9 character varying(20) NOT NULL DEFAULT ''::character varying,
  c10 character varying(18) NOT NULL DEFAULT ''::character varying,
  c11 character varying(80) NOT NULL DEFAULT ''::character varying,
  c12 character varying(5) NOT NULL DEFAULT ''::character varying,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying,
  c15 numeric(15,2) NOT NULL DEFAULT 0,
  c16 character varying NOT NULL DEFAULT 0,
  c17 character varying(4) NOT NULL DEFAULT ''::character varying,
  c18 character varying(4) NOT NULL DEFAULT ''::character varying,
  c19 character varying(4) NOT NULL DEFAULT ''::character varying,
  c20 character varying(2) NOT NULL DEFAULT ''::character varying,
  c21 character varying(11) NOT NULL DEFAULT ''::character varying,
  c22 character varying(2) NOT NULL DEFAULT ''::character varying,
  c23 character varying(11) NOT NULL DEFAULT ''::character varying,
  c24 character varying(40) NOT NULL DEFAULT ''::character varying,
  c25 character varying(40) NOT NULL DEFAULT ''::character varying,
  c26 character varying(40) NOT NULL DEFAULT ''::character varying,
  c27 character varying(10) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NULL,
  c29 character varying(1) NULL DEFAULT 'S'::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdxd ON keplersc.kdxd USING btree (c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxd02 ON keplersc.kdxd USING btree (c3, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxd03 ON keplersc.kdxd USING btree (c12, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxd04 ON keplersc.kdxd USING btree (c13, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxd05 ON keplersc.kdxd USING btree (c14, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdxd IS 'Proveedores';
COMMENT ON COLUMN keplersc.kdxd.c9 IS 'Fax';
COMMENT ON COLUMN keplersc.kdxd.c8 IS 'Telefono 2';
COMMENT ON COLUMN keplersc.kdxd.c7 IS 'Telefono';
COMMENT ON COLUMN keplersc.kdxd.c6 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdxd.c5 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdxd.c4 IS 'Calle numero';
COMMENT ON COLUMN keplersc.kdxd.c3 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdxd.c29 IS 'Validar CFDI';
COMMENT ON COLUMN keplersc.kdxd.c28 IS 'Solicitar RFC y CP';
COMMENT ON COLUMN keplersc.kdxd.c27 IS 'Codigo postal';
COMMENT ON COLUMN keplersc.kdxd.c26 IS 'Lugar entrega mercancia tres';
COMMENT ON COLUMN keplersc.kdxd.c25 IS 'Lugar entrega mercancia dos';
COMMENT ON COLUMN keplersc.kdxd.c24 IS 'Lugar entrega mercancia';
COMMENT ON COLUMN keplersc.kdxd.c23 IS 'Hora pago';
COMMENT ON COLUMN keplersc.kdxd.c22 IS 'Dia pago';
COMMENT ON COLUMN keplersc.kdxd.c21 IS 'Hora revision';
COMMENT ON COLUMN keplersc.kdxd.c20 IS 'Dia revision';
COMMENT ON COLUMN keplersc.kdxd.c2 IS 'Clave proveedor';
COMMENT ON COLUMN keplersc.kdxd.c19 IS 'Porcentaje tercer descuento';
COMMENT ON COLUMN keplersc.kdxd.c18 IS 'Porcentaje segundo descuento';
COMMENT ON COLUMN keplersc.kdxd.c17 IS 'Porcentaje descuento';
COMMENT ON COLUMN keplersc.kdxd.c16 IS 'Plazo credito';
COMMENT ON COLUMN keplersc.kdxd.c15 IS 'Limite credito';
COMMENT ON COLUMN keplersc.kdxd.c14 IS 'Clave zona';
COMMENT ON COLUMN keplersc.kdxd.c13 IS 'Clave grupo';
COMMENT ON COLUMN keplersc.kdxd.c12 IS 'Clave comprador';
COMMENT ON COLUMN keplersc.kdxd.c11 IS 'Email';
COMMENT ON COLUMN keplersc.kdxd.c10 IS 'RFC';
COMMENT ON COLUMN keplersc.kdxd.c1 IS 'Clave sucursal';

