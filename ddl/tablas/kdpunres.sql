CREATE  TABLE keplersc.kdpunres (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(8) NOT NULL DEFAULT ''::character varying,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(8) NOT NULL DEFAULT ''::character varying,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(300) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(300) NOT NULL DEFAULT ''::character varying,
  c15 character varying(300) NOT NULL DEFAULT ''::character varying,
  c16 character varying(300) NOT NULL DEFAULT ''::character varying,
  c17 character varying(20) NOT NULL DEFAULT ''::character varying,
  c18 character varying(20) NOT NULL DEFAULT ''::character varying,
  c19 numeric(15,2) NOT NULL DEFAULT 0,
  c20 character varying(5) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 character varying(10) NOT NULL DEFAULT ''::character varying,
  c25 character varying(17) NOT NULL DEFAULT ''::character varying,
  c26 character varying(70) NOT NULL DEFAULT ''::character varying,
  c27 character varying(70) NOT NULL DEFAULT ''::character varying,
  c28 character varying(70) NOT NULL DEFAULT ''::character varying,
  c29 character varying(70) NOT NULL DEFAULT ''::character varying,
  c30 character varying(70) NOT NULL DEFAULT ''::character varying,
  c31 character varying(70) NOT NULL DEFAULT ''::character varying,
  c32 character varying(1) NULL,
  c33 character varying(300) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpunres ADD CONSTRAINT pk_kdpunres PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdpunres02 ON keplersc.kdpunres USING btree (c25, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpunres03 ON keplersc.kdpunres USING btree (c1, c21, c6, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpunres04 ON keplersc.kdpunres USING btree (c1, c20, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpunres IS 'Recomendaciones para Puntos de Ordenes de Servicio';
COMMENT ON COLUMN keplersc.kdpunres.c9 IS 'Hora Final';
COMMENT ON COLUMN keplersc.kdpunres.c8 IS 'Fecha Final';
COMMENT ON COLUMN keplersc.kdpunres.c7 IS 'Hora Inicial';
COMMENT ON COLUMN keplersc.kdpunres.c6 IS 'Fecha Inicial';
COMMENT ON COLUMN keplersc.kdpunres.c5 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdpunres.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdpunres.c33 IS 'Recomendaciones del tecnico';
COMMENT ON COLUMN keplersc.kdpunres.c32 IS '¿El trabajo fue revisado por el Asesor Tecnico? (S,N)';
COMMENT ON COLUMN keplersc.kdpunres.c31 IS 'Recomendaciones 3';
COMMENT ON COLUMN keplersc.kdpunres.c30 IS 'Recomendaciones  2';
COMMENT ON COLUMN keplersc.kdpunres.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdpunres.c29 IS 'Recomendaciones 1';
COMMENT ON COLUMN keplersc.kdpunres.c28 IS 'Observaciones  3';
COMMENT ON COLUMN keplersc.kdpunres.c27 IS 'Observaciones 2';
COMMENT ON COLUMN keplersc.kdpunres.c26 IS 'Observaciones 1';
COMMENT ON COLUMN keplersc.kdpunres.c25 IS 'Serie';
COMMENT ON COLUMN keplersc.kdpunres.c24 IS 'Folio Garantia';
COMMENT ON COLUMN keplersc.kdpunres.c23 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdpunres.c22 IS '¿Aplico a garantia? (S,N)';
COMMENT ON COLUMN keplersc.kdpunres.c21 IS '¿Requirio llamar a Soporte tecnico? (S,N)';
COMMENT ON COLUMN keplersc.kdpunres.c20 IS 'Tecnico';
COMMENT ON COLUMN keplersc.kdpunres.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdpunres.c19 IS 'Tiempo Transcurrido';
COMMENT ON COLUMN keplersc.kdpunres.c18 IS 'Usuario JefeTaller';
COMMENT ON COLUMN keplersc.kdpunres.c17 IS 'UsuarioTecnico';
COMMENT ON COLUMN keplersc.kdpunres.c16 IS 'Recomendaciones';
COMMENT ON COLUMN keplersc.kdpunres.c15 IS 'Observaciones';
COMMENT ON COLUMN keplersc.kdpunres.c14 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdpunres.c13 IS '¿Se reparo la falla? (S,N)';
COMMENT ON COLUMN keplersc.kdpunres.c12 IS '¿Revisado? (S,N)';
COMMENT ON COLUMN keplersc.kdpunres.c11 IS 'Resultado';
COMMENT ON COLUMN keplersc.kdpunres.c10 IS 'Tiempo Transcurrido';
COMMENT ON COLUMN keplersc.kdpunres.c1 IS 'Sucursal';

