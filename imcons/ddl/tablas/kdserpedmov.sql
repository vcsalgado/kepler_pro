CREATE  TABLE keplersc.kdserpedmov (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(20) NOT NULL DEFAULT ''::character varying,
  c5 numeric(7,2) NOT NULL DEFAULT 0,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric NOT NULL DEFAULT 0,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdserpedmov ADD CONSTRAINT pk_kdserpedmov PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdserpedmov02 ON keplersc.kdserpedmov USING btree (c1, c8, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdserpedmov03 ON keplersc.kdserpedmov USING btree (c1, c10, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdserpedmov IS 'Pedidos Especiales detalles';
COMMENT ON COLUMN keplersc.kdserpedmov.c9 IS 'Fecha de Surtido';
COMMENT ON COLUMN keplersc.kdserpedmov.c8 IS '0 No Surtido 10 Surtido';
COMMENT ON COLUMN keplersc.kdserpedmov.c7 IS 'ETA';
COMMENT ON COLUMN keplersc.kdserpedmov.c6 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdserpedmov.c5 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdserpedmov.c4 IS 'Clave de la Pieza';
COMMENT ON COLUMN keplersc.kdserpedmov.c3 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdserpedmov.c2 IS 'Pedido';
COMMENT ON COLUMN keplersc.kdserpedmov.c13 IS 'Orden';
COMMENT ON COLUMN keplersc.kdserpedmov.c12 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdserpedmov.c11 IS 'Fecha de Entregado';
COMMENT ON COLUMN keplersc.kdserpedmov.c10 IS '0 No Entregado 10 Entregado';
COMMENT ON COLUMN keplersc.kdserpedmov.c1 IS 'Sucursal';

