CREATE  TABLE keplersc.kdactpreent (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdactpreent ADD CONSTRAINT pk_kdactpreent PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdactpreent02 ON keplersc.kdactpreent USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdactpreent IS 'Actividades pre etrega';
COMMENT ON COLUMN keplersc.kdactpreent.c3 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdactpreent.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdactpreent.c1 IS 'Clave';

