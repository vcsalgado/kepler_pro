CREATE  TABLE keplersc.kdif (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(16) NOT NULL DEFAULT ''::character varying,
  c4 character varying NOT NULL DEFAULT '1'::character varying,
  c5 character varying(16) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdif ON keplersc.kdif USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdif02 ON keplersc.kdif USING btree (c2, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdif IS 'Catalogo de grupos de productos';
COMMENT ON COLUMN keplersc.kdif.c4 IS 'Almacen';
COMMENT ON COLUMN keplersc.kdif.c3 IS 'Cuenta contable del costo de ventas';
COMMENT ON COLUMN keplersc.kdif.c2 IS 'Descripcion del grupo';
COMMENT ON COLUMN keplersc.kdif.c1 IS 'Clave del grupo';

