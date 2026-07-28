CREATE  TABLE keplersc.kdtmktser2 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 10,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 character varying(240) NOT NULL DEFAULT ''::character varying,
  c12 character varying(240) NOT NULL DEFAULT ''::character varying,
  c13 character varying(240) NOT NULL DEFAULT ''::character varying,
  c14 character varying(8) NULL DEFAULT ''::character varying,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(10) NOT NULL DEFAULT ''::character varying,
  c18 numeric NULL,
  c19 character varying(1) NULL DEFAULT 'P'::character varying,
  c20 character varying(7) NULL,
  c21 character varying NULL,
  c22 character varying NOT NULL DEFAULT ''::character varying,
  c23 numeric NOT NULL DEFAULT 10,
  c24 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c25 character varying(1) NOT NULL DEFAULT 'M'::character varying,
  c26 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c27 character varying NOT NULL DEFAULT ''::character varying,
  c28 character varying NOT NULL DEFAULT ''::character varying,
  c29 character varying(60) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktser2 ADD CONSTRAINT pk_kdtmktser2 PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdtmktser202 ON keplersc.kdtmktser2 USING btree (c1, c3, c4, c5, c6, c7, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser203 ON keplersc.kdtmktser2 USING btree (c1, c14, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser204 ON keplersc.kdtmktser2 USING btree (c1, c3, c8, c9, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser205 ON keplersc.kdtmktser2 USING btree (c1, c15, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtmktser206 ON keplersc.kdtmktser2 USING btree (c1, c16, c17, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtmktser2 IS 'Control Telemarketing';
COMMENT ON COLUMN keplersc.kdtmktser2.c9 IS 'Accion a tomar (kdtmktaccion)';
COMMENT ON COLUMN keplersc.kdtmktser2.c8 IS 'Resultado o Status Accion (kdtmktresult)';
COMMENT ON COLUMN keplersc.kdtmktser2.c7 IS 'Motivo Contacto (kdtmktmotivo)';
COMMENT ON COLUMN keplersc.kdtmktser2.c6 IS 'Tipo Contacto: 0 Recontacto Programado; 10 Contacto Nuevo;';
COMMENT ON COLUMN keplersc.kdtmktser2.c5 IS 'Fecha de programacion';
COMMENT ON COLUMN keplersc.kdtmktser2.c4 IS 'Esta en pantalla: 0 Si; 10 No;';
COMMENT ON COLUMN keplersc.kdtmktser2.c3 IS 'Asesor Base TMKT';
COMMENT ON COLUMN keplersc.kdtmktser2.c29 IS 'Motivo para Resultado Contacto sea No quiere se contactado, Cancelado o No Show';
COMMENT ON COLUMN keplersc.kdtmktser2.c28 IS 'Identificador Proceso 0 (recordatorio sig serv) , 10(unidad en taller), 20(diagnostico), 30(refs ordenadas), 40(refs recibidas), 50(unidad en rampa), 60(unidad lista)';
COMMENT ON COLUMN keplersc.kdtmktser2.c27 IS 'Asesor Real TMKT';
COMMENT ON COLUMN keplersc.kdtmktser2.c26 IS 'Fecha vale de salida/ultimo servicio';
COMMENT ON COLUMN keplersc.kdtmktser2.c25 IS 'Origen M(Manual), A(Automatico), (kdtmktorigen)';
COMMENT ON COLUMN keplersc.kdtmktser2.c24 IS 'Fecha de Creacion';
COMMENT ON COLUMN keplersc.kdtmktser2.c23 IS '0 llamada, 10 Correo, 20 Whatsapp, 30 SMS (kdmediocontacto)';
COMMENT ON COLUMN keplersc.kdtmktser2.c22 IS 'N-30, N-15, N+7,..... N-U(Urgente) (configurables(kdtmktserconf))';
COMMENT ON COLUMN keplersc.kdtmktser2.c21 IS 'Nombre de la persona con la que se tuvo el contacto';
COMMENT ON COLUMN keplersc.kdtmktser2.c20 IS 'Clave cliente';
COMMENT ON COLUMN keplersc.kdtmktser2.c2 IS 'Folio';
COMMENT ON COLUMN keplersc.kdtmktser2.c19 IS 'Tipo Trabajo: [P]roactivo; [R]eactivo';
COMMENT ON COLUMN keplersc.kdtmktser2.c18 IS 'Tipo servicio TMKT: 0 Servicio; 10 Ventas';
COMMENT ON COLUMN keplersc.kdtmktser2.c17 IS 'Folio de orden de Cita';
COMMENT ON COLUMN keplersc.kdtmktser2.c16 IS 'Tipo de orden de Cita';
COMMENT ON COLUMN keplersc.kdtmktser2.c15 IS 'Folio de la cita';
COMMENT ON COLUMN keplersc.kdtmktser2.c14 IS 'Serie';
COMMENT ON COLUMN keplersc.kdtmktser2.c13 IS 'Observacion 3';
COMMENT ON COLUMN keplersc.kdtmktser2.c12 IS 'Observacion 2';
COMMENT ON COLUMN keplersc.kdtmktser2.c11 IS 'Observacion 1';
COMMENT ON COLUMN keplersc.kdtmktser2.c10 IS 'Fecha de contacto real';
COMMENT ON COLUMN keplersc.kdtmktser2.c1 IS 'Sucursal';

