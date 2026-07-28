CREATE  TABLE keplersc.kdctasser (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 character varying(8) NOT NULL DEFAULT ''::character varying,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(17) NOT NULL DEFAULT ''::character varying,
  c10 character varying(4) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c17 character varying(6) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 numeric NOT NULL DEFAULT 0,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(10) NOT NULL DEFAULT ''::character varying,
  c23 character varying(6) NOT NULL DEFAULT ''::character varying,
  c24 character varying(10) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c27 character varying(5) NOT NULL DEFAULT ''::character varying,
  c28 character varying(80) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(300) NOT NULL DEFAULT ''::character varying,
  c31 character varying(110) NOT NULL DEFAULT ''::character varying,
  c32 character varying(110) NOT NULL DEFAULT ''::character varying,
  c33 character varying(110) NOT NULL DEFAULT ''::character varying,
  c34 character varying(110) NOT NULL DEFAULT ''::character varying,
  c35 character varying(110) NOT NULL DEFAULT ''::character varying,
  c36 character varying(15) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 character varying(15) NOT NULL DEFAULT ''::character varying,
  c39 character varying(1) NOT NULL DEFAULT ''::character varying,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  promocion character varying(7) NULL DEFAULT ''::character varying,
  tipo_servicio character varying(1) NULL DEFAULT ''::character varying,
  ubicacion_servicio character varying(7) NULL DEFAULT ''::character varying,
  calle_rec character varying(80) NULL DEFAULT ''::character varying,
  num_ext_rec character varying(15) NULL DEFAULT ''::character varying,
  num_int_rec character varying(15) NULL DEFAULT ''::character varying,
  colonia_rec character varying(70) NULL DEFAULT ''::character varying,
  poblacion_rec character varying(70) NULL DEFAULT ''::character varying,
  municipio_rec character varying(70) NULL DEFAULT ''::character varying,
  estado_rec character varying(35) NULL DEFAULT ''::character varying,
  cp_rec character varying(5) NULL DEFAULT ''::character varying,
  contacto_rec character varying(90) NULL DEFAULT ''::character varying,
  fecha_rec timestamp without time zone NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  hora_rec character varying(5) NULL DEFAULT ''::character varying,
  regresa_domicilio character varying(1) NULL DEFAULT ''::character varying,
  observaciones_rec character varying(300) NULL DEFAULT ''::character varying,
  col_alimento character varying(3) NOT NULL DEFAULT ''::character varying,
  col_bebida character varying(3) NOT NULL DEFAULT ''::character varying,
  col_amenidad character varying(3) NOT NULL DEFAULT ''::character varying,
  col_cita_en_linea character varying(1) NOT NULL DEFAULT ''::character varying,
  origen character varying(3) NOT NULL DEFAULT 'K80'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctasser ADD CONSTRAINT pk_kdctasser PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdctasser02 ON keplersc.kdctasser USING btree (c1, c20, c5, c37, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser03 ON keplersc.kdctasser USING btree (c1, c20, c6, c37, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser04 ON keplersc.kdctasser USING btree (c1, c20, c3, c12, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser05 ON keplersc.kdctasser USING btree (c1, c20, c37, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser06 ON keplersc.kdctasser USING btree (c1, c3, c16, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser07 ON keplersc.kdctasser USING btree (c1, c12, c13, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdctasser08 ON keplersc.kdctasser USING btree (c1, c21, c22, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdctasser IS 'Citas Servicios';
COMMENT ON COLUMN keplersc.kdctasser.ubicacion_servicio IS 'Ubicacion servicio valor catalogo kdsercatubica';
COMMENT ON COLUMN keplersc.kdctasser.tipo_servicio IS 'R=Recoleccion D=servicio a domicilio E=mantenimiento express';
COMMENT ON COLUMN keplersc.kdctasser.regresa_domicilio IS 'El auto se regresa a domicilio';
COMMENT ON COLUMN keplersc.kdctasser.promocion IS 'Promocion que aplique a la cita';
COMMENT ON COLUMN keplersc.kdctasser.poblacion_rec IS 'Poblacion para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.origen IS 'Sistema origen de registro';
COMMENT ON COLUMN keplersc.kdctasser.observaciones_rec IS 'Observaciones para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.num_int_rec IS 'Numero interior para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.num_ext_rec IS 'Numero exterior para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.municipio_rec IS 'Municipio para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.hora_rec IS 'Hora para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.fecha_rec IS 'Fecha para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.estado_rec IS 'Estado para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.cp_rec IS 'Codigo postal para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.contacto_rec IS 'Nombre de contacto para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.colonia_rec IS 'Colonia para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.col_cita_en_linea IS 'S o N';
COMMENT ON COLUMN keplersc.kdctasser.col_bebida IS 'Tipo de Bebida (kdsertipobebida)';
COMMENT ON COLUMN keplersc.kdctasser.col_amenidad IS 'Tipo de Amenidad';
COMMENT ON COLUMN keplersc.kdctasser.col_alimento IS 'Tipo de Snack (kdsertiposnack)';
COMMENT ON COLUMN keplersc.kdctasser.calle_rec IS 'Calle para recoleccion';
COMMENT ON COLUMN keplersc.kdctasser.c9 IS 'VIN';
COMMENT ON COLUMN keplersc.kdctasser.c8 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdctasser.c7 IS 'Marca';
COMMENT ON COLUMN keplersc.kdctasser.c6 IS 'ID VIN';
COMMENT ON COLUMN keplersc.kdctasser.c5 IS 'Placas';
COMMENT ON COLUMN keplersc.kdctasser.c4 IS 'Clave de cliente';
COMMENT ON COLUMN keplersc.kdctasser.c37 IS 'Tipo cita (N,G,I,Q,R)';
COMMENT ON COLUMN keplersc.kdctasser.c36 IS 'Katashiki';
COMMENT ON COLUMN keplersc.kdctasser.c35 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c34 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c33 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c32 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c31 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c30 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdctasser.c3 IS 'Cve de TMKT';
COMMENT ON COLUMN keplersc.kdctasser.c28 IS 'Nombre de la persona que confirma';
COMMENT ON COLUMN keplersc.kdctasser.c27 IS 'Hora de confirmacion';
COMMENT ON COLUMN keplersc.kdctasser.c26 IS 'Fecha de confirmacion';
COMMENT ON COLUMN keplersc.kdctasser.c24 IS 'Folio de la nueva cita';
COMMENT ON COLUMN keplersc.kdctasser.c23 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdctasser.c22 IS 'Folio de la orden';
COMMENT ON COLUMN keplersc.kdctasser.c21 IS 'Tipo de orden';
COMMENT ON COLUMN keplersc.kdctasser.c20 IS 'Pendiente=0; Confirmada=10; Concretada=20; Reprogramada=30; Cancelada=40; No Show=50';
COMMENT ON COLUMN keplersc.kdctasser.c2 IS 'Folio de cita';
COMMENT ON COLUMN keplersc.kdctasser.c17 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdctasser.c16 IS 'Fecha de registro';
COMMENT ON COLUMN keplersc.kdctasser.c15 IS 'Hora promesa de entrega';
COMMENT ON COLUMN keplersc.kdctasser.c14 IS 'Fecha promesa de entrega';
COMMENT ON COLUMN keplersc.kdctasser.c13 IS 'Hora de cita';
COMMENT ON COLUMN keplersc.kdctasser.c12 IS 'Fecha de cita';
COMMENT ON COLUMN keplersc.kdctasser.c11 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdctasser.c10 IS 'Anio modelo';
COMMENT ON COLUMN keplersc.kdctasser.c1 IS 'Sucursal';

