CREATE  TABLE keplersc.kdpedidosugeridoconf (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(6,2) NOT NULL DEFAULT 0,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 numeric(5,2) NOT NULL DEFAULT 0,
  c16 numeric(5,2) NOT NULL DEFAULT 0,
  c17 numeric(5,2) NOT NULL DEFAULT 0,
  c18 numeric(5,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdpedidosugeridoconf ON keplersc.kdpedidosugeridoconf USING btree (c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c9 IS 'Porcentaje minimo anticipo';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c8 IS 'Dias habiles mensuales';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c7 IS 'Ultimo phase In / Out generado';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c6 IS 'Pedido en curso';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c5 IS 'Formula Stock';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c4 IS 'Dias venta buscados diarios';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c3 IS 'Delay traslado';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c2 IS 'Dias de ventas buscados mensuales';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c18 IS 'SS Obsoleto';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c17 IS 'SS Bajo Movimiento';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c16 IS 'SS Alto Movimiento';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c15 IS 'SS Zona Dorada';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c14 IS 'Calcular stock de seguridad';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c13 IS 'Manejar VIN en pedido mostrador';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c12 IS 'Manejar desviacion standard';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c11 IS 'Aplicar porcentaje minimo';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c10 IS 'Usar inventario virtual';
COMMENT ON COLUMN keplersc.kdpedidosugeridoconf.c1 IS 'Sucursal';

