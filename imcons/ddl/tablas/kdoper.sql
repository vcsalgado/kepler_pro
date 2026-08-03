CREATE  TABLE keplersc.kdoper (
  c1 character varying(6) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying,
  c5 character varying(40) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(12) NOT NULL DEFAULT ''::character varying,
  c8 character varying(12) NOT NULL DEFAULT ''::character varying,
  c9 character varying(40) NOT NULL DEFAULT ''::character varying,
  c10 character varying(40) NOT NULL DEFAULT ''::character varying,
  c11 character varying(40) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric NOT NULL DEFAULT 0,
  c17 character varying(5) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(5) NOT NULL DEFAULT ''::character varying,
  c20 character varying(20) NOT NULL DEFAULT ''::character varying,
  c21 character varying(5) NOT NULL DEFAULT ''::character varying,
  c22 character varying(5) NOT NULL DEFAULT ''::character varying,
  c23 character varying(5) NOT NULL DEFAULT ''::character varying,
  c24 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdoper ADD CONSTRAINT pk_kdoper PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdoper02 ON keplersc.kdoper USING btree (c12, c2, c16, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoper03 ON keplersc.kdoper USING btree (c20) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoper04 ON keplersc.kdoper USING btree (c21, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoper05 ON keplersc.kdoper USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdoper.c9 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdoper.c8 IS 'Telefono 2';
COMMENT ON COLUMN keplersc.kdoper.c7 IS 'Telefono 1';
COMMENT ON COLUMN keplersc.kdoper.c6 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdoper.c5 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdoper.c4 IS 'Direccion';
COMMENT ON COLUMN keplersc.kdoper.c3 IS 'Nombre del Operario';
COMMENT ON COLUMN keplersc.kdoper.c24 IS 'Fin Horario Comida';
COMMENT ON COLUMN keplersc.kdoper.c23 IS 'Inicio Horario Comida';
COMMENT ON COLUMN keplersc.kdoper.c22 IS 'Ayudante';
COMMENT ON COLUMN keplersc.kdoper.c21 IS 'Jefe de Taller';
COMMENT ON COLUMN keplersc.kdoper.c20 IS 'Usuario de Kepler';
COMMENT ON COLUMN keplersc.kdoper.c2 IS 'Tipo de Operario';
COMMENT ON COLUMN keplersc.kdoper.c19 IS 'Operario de Lavado';
COMMENT ON COLUMN keplersc.kdoper.c18 IS 'Tomar en Cuenta para Pago Operarios';
COMMENT ON COLUMN keplersc.kdoper.c17 IS 'Tipo de Pago';
COMMENT ON COLUMN keplersc.kdoper.c16 IS 'Diferencia Activas-Maximo';
COMMENT ON COLUMN keplersc.kdoper.c15 IS 'Total de Ordenes Suspendidas';
COMMENT ON COLUMN keplersc.kdoper.c14 IS 'Total de Ordenes Activas';
COMMENT ON COLUMN keplersc.kdoper.c13 IS 'Maximo de Ordenes Abiertas';
COMMENT ON COLUMN keplersc.kdoper.c12 IS 'Activo';
COMMENT ON COLUMN keplersc.kdoper.c11 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdoper.c10 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdoper.c1 IS 'Clave';

