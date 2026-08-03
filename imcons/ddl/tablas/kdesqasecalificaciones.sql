CREATE  TABLE keplersc.kdesqasecalificaciones (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 numeric(5,2) NOT NULL DEFAULT 0,
  c5 numeric(5,2) NOT NULL DEFAULT 0,
  c6 numeric(5,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdesqasecalificaciones ADD CONSTRAINT pk_kdesqasecalificaciones PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdesqasecalificaciones IS 'Asesor esquema de calificaciones';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c6 IS 'Alcance de capacitacion';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c5 IS 'Aplicacion de procedimientos';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c4 IS 'CSI del Mes';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c2 IS 'Mes';
COMMENT ON COLUMN keplersc.kdesqasecalificaciones.c1 IS 'Asesor de servicio';

