CREATE  TABLE keplersc.kdxv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdxv02 ON keplersc.kdxv USING btree (c3, c2) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdxv ON keplersc.kdxv USING btree (c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdxv IS 'Agentes compras y ventas';
COMMENT ON COLUMN keplersc.kdxv.c3 IS 'Clave agente ventas';
COMMENT ON COLUMN keplersc.kdxv.c2 IS 'Clave agente compras';
COMMENT ON COLUMN keplersc.kdxv.c1 IS 'Sucursal';

