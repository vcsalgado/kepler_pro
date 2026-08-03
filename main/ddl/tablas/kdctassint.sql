CREATE  TABLE keplersc.kdctassint (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctassint ADD CONSTRAINT pk_kdctassint PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON TABLE keplersc.kdctassint IS 'Sintoma de cada punto de cita de Servicio';
COMMENT ON COLUMN keplersc.kdctassint.c7 IS 'comentarios';
COMMENT ON COLUMN keplersc.kdctassint.c6 IS 'Clave del Sintoma';
COMMENT ON COLUMN keplersc.kdctassint.c5 IS 'Tipo de Sintoma';
COMMENT ON COLUMN keplersc.kdctassint.c4 IS 'Partida';
COMMENT ON COLUMN keplersc.kdctassint.c3 IS 'Punto de la Cita';
COMMENT ON COLUMN keplersc.kdctassint.c2 IS 'Folio de la Cita';
COMMENT ON COLUMN keplersc.kdctassint.c1 IS 'Sucursal';

