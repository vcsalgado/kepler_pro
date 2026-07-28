CREATE  TABLE keplersc.kduv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(21) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kduv ADD CONSTRAINT pk_kduv PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkduv02 ON keplersc.kduv USING btree (c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduv03 ON keplersc.kduv USING btree (c3, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduv04 ON keplersc.kduv USING btree (c5, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkduv05 ON keplersc.kduv USING btree (c6, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kduv IS 'Catalogo de Vendedores';
COMMENT ON COLUMN keplersc.kduv.c9 IS 'fecha de ingreso';
COMMENT ON COLUMN keplersc.kduv.c8 IS 'esquema de comisiones';
COMMENT ON COLUMN keplersc.kduv.c7 IS 'grupo';
COMMENT ON COLUMN keplersc.kduv.c6 IS 'activo';
COMMENT ON COLUMN keplersc.kduv.c5 IS 'usuario';
COMMENT ON COLUMN keplersc.kduv.c4 IS 'empresa a la que pertenece';
COMMENT ON COLUMN keplersc.kduv.c3 IS 'nombre vendedor';
COMMENT ON COLUMN keplersc.kduv.c2 IS 'clave vendedor';
COMMENT ON COLUMN keplersc.kduv.c1 IS 'sucursal';

