CREATE  TABLE keplersc.kdpuntop (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpuntop ADD CONSTRAINT pk_kdpuntop PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdpuntop02 ON keplersc.kdpuntop USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpuntop IS 'Tipo punto - Operario';
COMMENT ON COLUMN keplersc.kdpuntop.c2 IS 'Tipo de Operario';
COMMENT ON COLUMN keplersc.kdpuntop.c1 IS 'Tipo de Trabajo';

