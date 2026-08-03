CREATE  TABLE keplersc.kdcomp (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(70) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcomp ADD CONSTRAINT pk_kdcomp PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcomp02 ON keplersc.kdcomp USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdcomp.c3 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdcomp.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcomp.c1 IS 'Clave';

