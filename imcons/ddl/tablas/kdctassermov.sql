CREATE  TABLE keplersc.kdctassermov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(100) NOT NULL DEFAULT ''::character varying,
  c8 numeric(12,2) NOT NULL DEFAULT 0,
  c9 numeric(6,3) NOT NULL DEFAULT 0,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 character varying NULL,
  c12 character varying(5) NOT NULL DEFAULT ''::character varying,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctassermov ADD CONSTRAINT pk_kdctassermov PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdctassermov IS 'Puntos de las Citas de Servicio';
COMMENT ON COLUMN keplersc.kdctassermov.c9 IS 'Horas a programar';
COMMENT ON COLUMN keplersc.kdctassermov.c8 IS 'Precio';
COMMENT ON COLUMN keplersc.kdctassermov.c7 IS 'Trabajo a Realizar';
COMMENT ON COLUMN keplersc.kdctassermov.c6 IS 'Clave del Paquete';
COMMENT ON COLUMN keplersc.kdctassermov.c5 IS 'Tipo de Operario';
COMMENT ON COLUMN keplersc.kdctassermov.c4 IS 'Autorizacion o Tipo de Punto';
COMMENT ON COLUMN keplersc.kdctassermov.c3 IS 'Punto';
COMMENT ON COLUMN keplersc.kdctassermov.c2 IS 'Folio de la Cita';
COMMENT ON COLUMN keplersc.kdctassermov.c13 IS 'Horario Fin';
COMMENT ON COLUMN keplersc.kdctassermov.c12 IS 'Horario Inicio';
COMMENT ON COLUMN keplersc.kdctassermov.c11 IS 'Clave Campaña';
COMMENT ON COLUMN keplersc.kdctassermov.c10 IS 'Clave Operario';
COMMENT ON COLUMN keplersc.kdctassermov.c1 IS 'Sucursal';

