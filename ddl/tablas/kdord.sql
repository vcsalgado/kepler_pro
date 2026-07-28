CREATE  TABLE keplersc.kdord (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(8) NOT NULL DEFAULT ''::character varying,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(130) NOT NULL DEFAULT ''::character varying,
  c12 character varying(80) NOT NULL DEFAULT ''::character varying,
  c13 character varying(70) NOT NULL DEFAULT ''::character varying,
  c14 character varying(70) NOT NULL DEFAULT ''::character varying,
  c15 character varying(20) NOT NULL DEFAULT ''::character varying,
  c16 character varying(20) NOT NULL DEFAULT ''::character varying,
  c17 character varying(20) NOT NULL DEFAULT ''::character varying,
  c18 character varying(5) NOT NULL DEFAULT ''::character varying,
  c19 character varying(5) NOT NULL DEFAULT ''::character varying,
  c20 numeric(15,2) NOT NULL DEFAULT 0,
  c21 character varying(10) NOT NULL DEFAULT ''::character varying,
  c22 character varying(6) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying NOT NULL DEFAULT ''::character varying,
  c25 character varying(90) NOT NULL DEFAULT ''::character varying,
  c26 character varying(90) NOT NULL DEFAULT ''::character varying,
  c27 character varying(90) NOT NULL DEFAULT ''::character varying,
  c28 character varying(90) NOT NULL DEFAULT ''::character varying,
  c29 character varying(90) NOT NULL DEFAULT ''::character varying,
  c30 numeric(20,6) NOT NULL DEFAULT 0,
  c31 numeric(20,6) NOT NULL DEFAULT 0,
  c32 numeric(20,6) NOT NULL DEFAULT 0,
  c33 numeric(20,6) NOT NULL DEFAULT 0,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying,
  c35 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c36 numeric NOT NULL DEFAULT 0,
  c37 numeric NOT NULL DEFAULT 0,
  c38 character varying(1) NOT NULL DEFAULT ''::character varying,
  c39 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c40 character varying(1) NOT NULL DEFAULT ''::character varying,
  c41 character varying(1) NOT NULL DEFAULT ''::character varying,
  c42 numeric NOT NULL DEFAULT 0,
  c43 numeric NOT NULL DEFAULT 0,
  c44 character varying(10) NOT NULL DEFAULT ''::character varying,
  c45 character varying(1) NOT NULL DEFAULT ''::character varying,
  c46 character varying(10) NOT NULL DEFAULT ''::character varying,
  c47 character varying(1) NOT NULL DEFAULT ''::character varying,
  c48 character varying(1) NOT NULL DEFAULT ''::character varying,
  c49 character varying(1) NOT NULL DEFAULT ''::character varying,
  c50 character varying(1) NOT NULL DEFAULT ''::character varying,
  c51 character varying(1) NOT NULL DEFAULT ''::character varying,
  c52 character varying(1) NOT NULL DEFAULT ''::character varying,
  c53 character varying(1) NOT NULL DEFAULT ''::character varying,
  c54 character varying(90) NOT NULL DEFAULT ''::character varying,
  c55 character varying(20) NOT NULL DEFAULT ''::character varying,
  c56 character varying(27) NOT NULL DEFAULT ''::character varying,
  c57 character varying(27) NOT NULL DEFAULT ''::character varying,
  c58 character varying(70) NOT NULL DEFAULT ''::character varying,
  c59 character varying(35) NOT NULL DEFAULT ''::character varying,
  c60 character varying(35) NOT NULL DEFAULT ''::character varying,
  c61 numeric(15,6) NOT NULL DEFAULT 0,
  c62 numeric(15,6) NOT NULL DEFAULT 0,
  c63 numeric(15,2) NOT NULL DEFAULT 0,
  kms_salida numeric(15,2) NULL DEFAULT 0,
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
  observaciones_rec character varying(300) NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdord ADD CONSTRAINT pk_kdord PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdord05 ON keplersc.kdord USING btree (c1, c6, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord06 ON keplersc.kdord USING btree (c1, c7, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord07 ON keplersc.kdord USING btree (c1, c8, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord08 ON keplersc.kdord USING btree (c1, c6, c7, c4, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord02 ON keplersc.kdord USING btree (c1, c11, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord03 ON keplersc.kdord USING btree (c1, c7, c11, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdord04 ON keplersc.kdord USING btree (c1, c8, c11, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdord IS 'Ordenes de Servicio';
COMMENT ON COLUMN keplersc.kdord.ubicacion_servicio IS 'Ubicacion servicio valor catalogo kdsercatubica';
COMMENT ON COLUMN keplersc.kdord.tipo_servicio IS 'R=Recoleccion D=servicio a domicilio E=mantenimiento express';
COMMENT ON COLUMN keplersc.kdord.regresa_domicilio IS 'El auto se regresa a domicilio';
COMMENT ON COLUMN keplersc.kdord.promocion IS 'Promocion que aplique a la orden';
COMMENT ON COLUMN keplersc.kdord.poblacion_rec IS 'Poblacion para recoleccion';
COMMENT ON COLUMN keplersc.kdord.observaciones_rec IS 'Observaciones para recoleccion';
COMMENT ON COLUMN keplersc.kdord.num_int_rec IS 'Numero interior para recoleccion';
COMMENT ON COLUMN keplersc.kdord.num_ext_rec IS 'Numero exterior para recoleccion';
COMMENT ON COLUMN keplersc.kdord.municipio_rec IS 'Municipio para recoleccion';
COMMENT ON COLUMN keplersc.kdord.kms_salida IS 'Kilometraje de salida';
COMMENT ON COLUMN keplersc.kdord.hora_rec IS 'Hora para recoleccion';
COMMENT ON COLUMN keplersc.kdord.fecha_rec IS 'Fecha para recoleccion';
COMMENT ON COLUMN keplersc.kdord.estado_rec IS 'Estado para recoleccion';
COMMENT ON COLUMN keplersc.kdord.cp_rec IS 'Codigo postal para recoleccion';
COMMENT ON COLUMN keplersc.kdord.contacto_rec IS 'Nombre de contacto para recoleccion';
COMMENT ON COLUMN keplersc.kdord.colonia_rec IS 'Colonia para recoleccion';
COMMENT ON COLUMN keplersc.kdord.calle_rec IS 'Calle para recoleccion';
COMMENT ON COLUMN keplersc.kdord.c8 IS 'Flujo Servicio. 0 Pendiente; 10 Activo; 20 Suspendido; 30 Terminado; 40 Cerrada; 50 Fuera de Taller';
COMMENT ON COLUMN keplersc.kdord.c7 IS 'Flujo admon 0 Abierta; 10 Cerrada para facturar; 20 Lista para imprimir Vale de salida; 30 Vale de Salida impreso';
COMMENT ON COLUMN keplersc.kdord.c63 IS 'Importe Total Orden';
COMMENT ON COLUMN keplersc.kdord.c62 IS 'Iva Orden';
COMMENT ON COLUMN keplersc.kdord.c61 IS 'Subtotal Orden';
COMMENT ON COLUMN keplersc.kdord.c60 IS 'Pais';
COMMENT ON COLUMN keplersc.kdord.c6 IS 'Serie Vehiculo';
COMMENT ON COLUMN keplersc.kdord.c59 IS 'Estado';
COMMENT ON COLUMN keplersc.kdord.c58 IS 'Municipio';
COMMENT ON COLUMN keplersc.kdord.c57 IS 'Numero Interior';
COMMENT ON COLUMN keplersc.kdord.c56 IS 'Numero Exterior';
COMMENT ON COLUMN keplersc.kdord.c55 IS 'Siniestro';
COMMENT ON COLUMN keplersc.kdord.c54 IS 'Nombre del Contacto(persona)';
COMMENT ON COLUMN keplersc.kdord.c53 IS 'Desea ser contactado S/N';
COMMENT ON COLUMN keplersc.kdord.c52 IS 'Impresa S/N';
COMMENT ON COLUMN keplersc.kdord.c51 IS 'Grupo de Folio';
COMMENT ON COLUMN keplersc.kdord.c50 IS 'Clasificacion (MAyor en tipo de punto)';
COMMENT ON COLUMN keplersc.kdord.c5 IS 'Hora de Recepcion';
COMMENT ON COLUMN keplersc.kdord.c49 IS 'Cita';
COMMENT ON COLUMN keplersc.kdord.c48 IS 'VEhiculo Presente (S/N)';
COMMENT ON COLUMN keplersc.kdord.c47 IS 'Tipo de Orden Reclamada';
COMMENT ON COLUMN keplersc.kdord.c46 IS 'Folio de la Orden Reclamada';
COMMENT ON COLUMN keplersc.kdord.c44 IS 'Folio de la FActura';
COMMENT ON COLUMN keplersc.kdord.c43 IS 'Tipo de la Factura';
COMMENT ON COLUMN keplersc.kdord.c42 IS 'Grupo de la Factura';
COMMENT ON COLUMN keplersc.kdord.c41 IS 'Naturaleza de la Factura';
COMMENT ON COLUMN keplersc.kdord.c40 IS 'Genero de la Factura';
COMMENT ON COLUMN keplersc.kdord.c4 IS 'Fecha de la Orden';
COMMENT ON COLUMN keplersc.kdord.c39 IS 'Fecha de Facturación';
COMMENT ON COLUMN keplersc.kdord.c37 IS 'Hora de cierre de la orden';
COMMENT ON COLUMN keplersc.kdord.c36 IS 'Hora de recepcion';
COMMENT ON COLUMN keplersc.kdord.c35 IS 'Fecha de Cierre de la orden';
COMMENT ON COLUMN keplersc.kdord.c33 IS 'Total a Cobrar de Cargos Varios sin Iva';
COMMENT ON COLUMN keplersc.kdord.c32 IS 'Total a Cobrar de TOTs sin Iva';
COMMENT ON COLUMN keplersc.kdord.c31 IS 'Total a Cobrar de Refacciones sin Iva';
COMMENT ON COLUMN keplersc.kdord.c30 IS 'Total a Cobrar de Mano de Obra sin Iva';
COMMENT ON COLUMN keplersc.kdord.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdord.c29 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c28 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c27 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c26 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c25 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c24 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdord.c22 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdord.c21 IS 'Placas';
COMMENT ON COLUMN keplersc.kdord.c20 IS 'Kilometraje';
COMMENT ON COLUMN keplersc.kdord.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdord.c19 IS 'Bonete';
COMMENT ON COLUMN keplersc.kdord.c18 IS 'Codigo Postal';
COMMENT ON COLUMN keplersc.kdord.c17 IS 'RFC';
COMMENT ON COLUMN keplersc.kdord.c16 IS 'Telefono';
COMMENT ON COLUMN keplersc.kdord.c15 IS 'Telefono';
COMMENT ON COLUMN keplersc.kdord.c14 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdord.c13 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdord.c12 IS 'Direccion';
COMMENT ON COLUMN keplersc.kdord.c11 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdord.c10 IS 'Clave del Cliente';
COMMENT ON COLUMN keplersc.kdord.c1 IS 'Sucursal';

