CREATE  TABLE keplersc.kdpedidoextras (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(10) NOT NULL DEFAULT ''::character varying,
  c5 character varying(80) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 numeric(5,2) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedidoextras ADD CONSTRAINT pk_kdpedidoextras PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON COLUMN keplersc.kdpedidoextras.c9 IS 'Importe';
COMMENT ON COLUMN keplersc.kdpedidoextras.c8 IS 'Precio';
COMMENT ON COLUMN keplersc.kdpedidoextras.c7 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdpedidoextras.c6 IS 'Unidad del SAT';
COMMENT ON COLUMN keplersc.kdpedidoextras.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdpedidoextras.c4 IS 'Clave del SAT';
COMMENT ON COLUMN keplersc.kdpedidoextras.c3 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdpedidoextras.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdpedidoextras.c1 IS 'Sucursal';

