CREATE  TABLE keplersc.kdctasbienvser (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 character varying(8) NOT NULL DEFAULT ''::character varying,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying,
  c8 character varying(205) NOT NULL DEFAULT ''::character varying,
  c9 character varying(20) NOT NULL DEFAULT ''::character varying,
  c10 character varying(4) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 character varying(50) NOT NULL DEFAULT ''::character varying,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c17 character varying(6) NOT NULL DEFAULT ''::character varying,
  c18 character varying(50) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric NOT NULL DEFAULT 0,
  c21 character varying(3) NOT NULL DEFAULT ''::character varying,
  c22 character varying(40) NOT NULL DEFAULT ''::character varying,
  c23 character varying(3) NOT NULL DEFAULT ''::character varying,
  c24 character varying(40) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c27 character varying(5) NOT NULL DEFAULT ''::character varying,
  c28 character varying(50) NOT NULL DEFAULT ''::character varying,
  c29 character varying(5) NOT NULL DEFAULT ''::character varying,
  c30 character varying(300) NOT NULL DEFAULT ''::character varying,
  c31 character varying(5) NOT NULL DEFAULT ''::character varying,
  c32 character varying(20) NOT NULL DEFAULT ''::character varying,
  c33 character varying(7) NOT NULL DEFAULT ''::character varying,
  c34 character varying(3) NOT NULL DEFAULT ''::character varying,
  c35 character varying(40) NOT NULL DEFAULT ''::character varying,
  c36 character varying(3) NOT NULL DEFAULT ''::character varying,
  c37 character varying(40) NOT NULL DEFAULT ''::character varying,
  c38 character varying(5) NOT NULL DEFAULT ''::character varying,
  c39 character varying(20) NOT NULL DEFAULT ''::character varying,
  c40 character varying(15) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctasbienvser ADD CONSTRAINT pk_kdctasbienvser PRIMARY KEY (c1, c15);
CREATE INDEX IF NOT EXISTS sindkdctasbienvser02 ON keplersc.kdctasbienvser USING btree (c1, c20, c5, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasbienvser03 ON keplersc.kdctasbienvser USING btree (c1, c20, c6, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasbienvser04 ON keplersc.kdctasbienvser USING btree (c1, c20, c3, c12, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasbienvser05 ON keplersc.kdctasbienvser USING btree (c1, c20, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasbienvser06 ON keplersc.kdctasbienvser USING btree (c1, c3, c16, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasbienvser07 ON keplersc.kdctasbienvser USING btree (c1, c12, c13, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdctasbienvser IS 'Evento Bienvenida';
COMMENT ON COLUMN keplersc.kdctasbienvser.c9 IS 'VIN';
COMMENT ON COLUMN keplersc.kdctasbienvser.c8 IS 'Descripcion vehiculo';
COMMENT ON COLUMN keplersc.kdctasbienvser.c7 IS 'Marca';
COMMENT ON COLUMN keplersc.kdctasbienvser.c6 IS 'ID VIN';
COMMENT ON COLUMN keplersc.kdctasbienvser.c5 IS 'Placas';
COMMENT ON COLUMN keplersc.kdctasbienvser.c40 IS 'Codigo Planta (Katashiki)';
COMMENT ON COLUMN keplersc.kdctasbienvser.c4 IS 'Clave de cliente contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c39 IS 'Numero preferido de contacto del propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c38 IS 'Medio preferido de contacto del propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c37 IS 'Descripcion de bebida contacto propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c36 IS 'Tipo de bebida contacto propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c35 IS 'Descripcion de snack contacto propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c34 IS 'Tipo de snack contacto propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c33 IS 'Clave de cliente contacto propietario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c32 IS 'Numero preferido de contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c31 IS 'Medio preferido de contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c30 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasbienvser.c3 IS 'Cve de TMKT o Usuario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c29 IS 'Numero de concesionario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c28 IS 'Nombre de la persona que confirma';
COMMENT ON COLUMN keplersc.kdctasbienvser.c27 IS 'Hora de confirmacion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c26 IS 'Fecha de confirmacion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c25 IS '0-Asistira otro; 1-Asistira el cliente';
COMMENT ON COLUMN keplersc.kdctasbienvser.c24 IS 'Descripcion de bebida contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c23 IS 'Tipo de bebida contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c22 IS 'Descripcion de snack contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c21 IS 'Tipo de snack contacto adquisicion';
COMMENT ON COLUMN keplersc.kdctasbienvser.c20 IS 'Pendiente=0; Confirmada=10;';
COMMENT ON COLUMN keplersc.kdctasbienvser.c2 IS 'Folio de cita';
COMMENT ON COLUMN keplersc.kdctasbienvser.c19 IS 'Asistio al evento de bienvenida';
COMMENT ON COLUMN keplersc.kdctasbienvser.c18 IS 'Nombre de la persona que asistira al evento';
COMMENT ON COLUMN keplersc.kdctasbienvser.c17 IS 'Vendedor';
COMMENT ON COLUMN keplersc.kdctasbienvser.c16 IS 'Fecha de registro';
COMMENT ON COLUMN keplersc.kdctasbienvser.c15 IS 'No. Inventario';
COMMENT ON COLUMN keplersc.kdctasbienvser.c14 IS 'Color';
COMMENT ON COLUMN keplersc.kdctasbienvser.c13 IS 'Hora de cita';
COMMENT ON COLUMN keplersc.kdctasbienvser.c12 IS 'Fecha de cita';
COMMENT ON COLUMN keplersc.kdctasbienvser.c11 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdctasbienvser.c10 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdctasbienvser.c1 IS 'Sucursal';

