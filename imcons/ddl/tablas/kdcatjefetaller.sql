CREATE  TABLE keplersc.kdcatjefetaller (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatjefetaller ADD CONSTRAINT pk_kdcatjefetaller PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdcatjefetaller IS 'Catalogo jefes de taller';
COMMENT ON COLUMN keplersc.kdcatjefetaller.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdcatjefetaller.c1 IS 'Clave';

