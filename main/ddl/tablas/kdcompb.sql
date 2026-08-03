CREATE  TABLE keplersc.kdcompb (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(70) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcompb ADD CONSTRAINT pk_kdcompb PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcompb02 ON keplersc.kdcompb USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdcompb.c3 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdcompb.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcompb.c1 IS 'Clave';

