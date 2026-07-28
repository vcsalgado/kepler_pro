CREATE  TABLE keplersc.kdage (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 character varying(80) NOT NULL DEFAULT ''::character varying,
  c7 character varying(80) NOT NULL DEFAULT ''::character varying,
  c8 character varying(80) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 character varying(80) NOT NULL DEFAULT ''::character varying,
  c12 character varying(80) NOT NULL DEFAULT ''::character varying,
  c13 character varying(80) NOT NULL DEFAULT ''::character varying,
  c14 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdage ADD CONSTRAINT pk_kdage PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdage02 ON keplersc.kdage USING btree (c14, c4, c5, c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdage03 ON keplersc.kdage USING btree (c14, c4, c9, c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdage04 ON keplersc.kdage USING btree (c1, c2, c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdage05 ON keplersc.kdage USING btree (c4, c14, c10, c9, c1, c2, c3) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdage.c9 IS 'Fecha realizacion';
COMMENT ON COLUMN keplersc.kdage.c8 IS 'Actividad a realizar 3';
COMMENT ON COLUMN keplersc.kdage.c7 IS 'Actividad a realizar 2';
COMMENT ON COLUMN keplersc.kdage.c6 IS 'Actividad a realizar 1';
COMMENT ON COLUMN keplersc.kdage.c5 IS 'Fecha programada';
COMMENT ON COLUMN keplersc.kdage.c4 IS 'Estado: 0 - Por realizar  10 - Realizado';
COMMENT ON COLUMN keplersc.kdage.c3 IS 'Consecutivo agendas';
COMMENT ON COLUMN keplersc.kdage.c2 IS 'Folio perfil';
COMMENT ON COLUMN keplersc.kdage.c14 IS 'Clave vendedor';
COMMENT ON COLUMN keplersc.kdage.c13 IS 'Conclusiones 3';
COMMENT ON COLUMN keplersc.kdage.c12 IS 'Conclusiones 2';
COMMENT ON COLUMN keplersc.kdage.c11 IS 'Conclusiones 1';
COMMENT ON COLUMN keplersc.kdage.c10 IS 'Tipo contacto';
COMMENT ON COLUMN keplersc.kdage.c1 IS 'Letra perfil';

