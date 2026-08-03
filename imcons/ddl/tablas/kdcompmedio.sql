CREATE  TABLE keplersc.kdcompmedio (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(70) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcompmedio ADD CONSTRAINT pk_kdcompmedio PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcompmedio02 ON keplersc.kdcompmedio USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdcompmedio.c3 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdcompmedio.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcompmedio.c1 IS 'Clave';

