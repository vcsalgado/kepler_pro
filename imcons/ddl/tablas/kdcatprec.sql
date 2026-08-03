CREATE  TABLE keplersc.kdcatprec (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatprec ADD CONSTRAINT pk_kdcatprec PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcatprec02 ON keplersc.kdcatprec USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdcatprec.c4 IS 'Tipo de punto';
COMMENT ON COLUMN keplersc.kdcatprec.c3 IS 'Clave de punto';
COMMENT ON COLUMN keplersc.kdcatprec.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcatprec.c1 IS 'Clave';

