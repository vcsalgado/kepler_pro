CREATE  TABLE keplersc.kdie (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdie ADD CONSTRAINT pk_kdie PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdie02 ON keplersc.kdie USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdie.c5 IS 'Almacen explosion';
COMMENT ON COLUMN keplersc.kdie.c4 IS 'Almacen default';
COMMENT ON COLUMN keplersc.kdie.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdie.c1 IS 'Clave tipo producto';

