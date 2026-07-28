CREATE  TABLE keplersc.kdserped (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(18) NOT NULL DEFAULT ''::character varying,
  c5 character varying(7) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdserped ADD CONSTRAINT pk_kdserped PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdserped02 ON keplersc.kdserped USING btree (c1, c13, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserped03 ON keplersc.kdserped USING btree (c1, c14, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserped04 ON keplersc.kdserped USING btree (c1, c4, c13, c14, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserped05 ON keplersc.kdserped USING btree (c1, c4, c14, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdserped IS 'Pedidos Especiales';
COMMENT ON COLUMN keplersc.kdserped.c9 IS 'Tipo Recibo';
COMMENT ON COLUMN keplersc.kdserped.c8 IS 'Grupo Recibo';
COMMENT ON COLUMN keplersc.kdserped.c7 IS 'Naturaleza Recibo';
COMMENT ON COLUMN keplersc.kdserped.c6 IS 'Genero Recibo';
COMMENT ON COLUMN keplersc.kdserped.c5 IS 'Clave del Cliente';
COMMENT ON COLUMN keplersc.kdserped.c4 IS 'VIN';
COMMENT ON COLUMN keplersc.kdserped.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdserped.c2 IS 'Pedido Especial';
COMMENT ON COLUMN keplersc.kdserped.c14 IS '0 Sin Entregar 10 Totalmente entregado';
COMMENT ON COLUMN keplersc.kdserped.c13 IS '0 Sin surtir 10 Totalmente surtido';
COMMENT ON COLUMN keplersc.kdserped.c12 IS 'Numero de Orden';
COMMENT ON COLUMN keplersc.kdserped.c11 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdserped.c10 IS 'Folio Recibo';
COMMENT ON COLUMN keplersc.kdserped.c1 IS 'Sucursal';

