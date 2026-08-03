CREATE  TABLE keplersc.kdtipsin (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtipsin ADD CONSTRAINT pk_kdtipsin PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdtipsin02 ON keplersc.kdtipsin USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtipsin.c3 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdtipsin.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtipsin.c1 IS 'Clave';

