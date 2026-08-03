CREATE  TABLE keplersc.kdperfil (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(2) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(5) NOT NULL DEFAULT ''::character varying,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 character varying(50) NOT NULL DEFAULT ''::character varying,
  c13 character varying(50) NOT NULL DEFAULT ''::character varying,
  c14 character varying(50) NOT NULL DEFAULT ''::character varying,
  c15 character varying(50) NOT NULL DEFAULT ''::character varying,
  c16 character varying(50) NOT NULL DEFAULT ''::character varying,
  c17 character varying(50) NOT NULL DEFAULT ''::character varying,
  c18 character varying(50) NOT NULL DEFAULT ''::character varying,
  c19 character varying(50) NOT NULL DEFAULT ''::character varying,
  c20 character varying(7) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 numeric NOT NULL DEFAULT 0,
  c24 numeric NOT NULL DEFAULT 0,
  c25 character varying(10) NOT NULL DEFAULT ''::character varying,
  c26 character varying(5) NOT NULL DEFAULT ''::character varying,
  c27 character varying(1) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(5) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 character varying(1) NOT NULL DEFAULT ''::character varying,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdperfil ADD CONSTRAINT pk_kdperfil PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdperfil02 ON keplersc.kdperfil USING btree (c6, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil03 ON keplersc.kdperfil USING btree (c6, c9, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil04 ON keplersc.kdperfil USING btree (c26, c4, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil05 ON keplersc.kdperfil USING btree (c6, c9, c7, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil06 ON keplersc.kdperfil USING btree (c20, c21, c22, c23, c24, c25, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil07 ON keplersc.kdperfil USING btree (c3, c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdperfil08 ON keplersc.kdperfil USING btree (c29, c4, c1, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdperfil.c9 IS 'Vendedor activo';
COMMENT ON COLUMN keplersc.kdperfil.c8 IS 'Tipo 0-Venta 10-Cortesia';
COMMENT ON COLUMN keplersc.kdperfil.c6 IS 'Fecha de cierre';
COMMENT ON COLUMN keplersc.kdperfil.c5 IS 'Estado 0-Abierto 10-Cerrado 20-Vendido';
COMMENT ON COLUMN keplersc.kdperfil.c4 IS 'Fecha de apertura';
COMMENT ON COLUMN keplersc.kdperfil.c34 IS 'Cliente be back';
COMMENT ON COLUMN keplersc.kdperfil.c33 IS 'Hoja de opciones';
COMMENT ON COLUMN keplersc.kdperfil.c32 IS 'Escoje una unidad';
COMMENT ON COLUMN keplersc.kdperfil.c31 IS 'Prueba de manejo';
COMMENT ON COLUMN keplersc.kdperfil.c30 IS 'Demostracion estatica';
COMMENT ON COLUMN keplersc.kdperfil.c3 IS 'Clave del prospecto';
COMMENT ON COLUMN keplersc.kdperfil.c29 IS 'Coach';
COMMENT ON COLUMN keplersc.kdperfil.c28 IS 'Prueba de manejo';
COMMENT ON COLUMN keplersc.kdperfil.c27 IS 'Operacion caliente';
COMMENT ON COLUMN keplersc.kdperfil.c26 IS 'Vendedor original';
COMMENT ON COLUMN keplersc.kdperfil.c25 IS 'Folio';
COMMENT ON COLUMN keplersc.kdperfil.c24 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdperfil.c23 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdperfil.c22 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdperfil.c21 IS 'Genero';
COMMENT ON COLUMN keplersc.kdperfil.c20 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdperfil.c2 IS 'Folio Perfil';
COMMENT ON COLUMN keplersc.kdperfil.c19 IS 'Observaciones del cierre 8';
COMMENT ON COLUMN keplersc.kdperfil.c18 IS 'Observaciones del cierre 7';
COMMENT ON COLUMN keplersc.kdperfil.c17 IS 'Observaciones del cierre 6';
COMMENT ON COLUMN keplersc.kdperfil.c16 IS 'Observaciones del cierre 5';
COMMENT ON COLUMN keplersc.kdperfil.c15 IS 'Observaciones del cierre 4';
COMMENT ON COLUMN keplersc.kdperfil.c14 IS 'Observaciones del cierre 3';
COMMENT ON COLUMN keplersc.kdperfil.c13 IS 'Observaciones del cierre 2';
COMMENT ON COLUMN keplersc.kdperfil.c12 IS 'Observaciones del cierre 1';
COMMENT ON COLUMN keplersc.kdperfil.c11 IS 'Tipo de contacto';
COMMENT ON COLUMN keplersc.kdperfil.c10 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdperfil.c1 IS 'Letra Perfil';

