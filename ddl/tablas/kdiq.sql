CREATE  TABLE keplersc.kdiq (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdiq ON keplersc.kdiq USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdiq02 ON keplersc.kdiq USING btree (c1, c3, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdiq IS 'Almacenes';
COMMENT ON COLUMN keplersc.kdiq.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdiq.c2 IS 'Alamacen';
COMMENT ON COLUMN keplersc.kdiq.c1 IS 'Sucursal';

