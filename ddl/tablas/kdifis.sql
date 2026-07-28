CREATE  TABLE keplersc.kdifis (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(40) NOT NULL DEFAULT ''::character varying,
  c6 numeric(15,5) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 numeric(15,5) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  folio_marbe numeric NOT NULL DEFAULT 0,
  cantidad_sis numeric NOT NULL DEFAULT 0,
  costo_invent_sis numeric NOT NULL DEFAULT 0,
  costo_invent_real numeric NOT NULL DEFAULT 0,
  estatus character varying(20) NULL DEFAULT 'PENDIENTE'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdifis ADD CONSTRAINT kdifis_pk PRIMARY KEY (c1, c2);
COMMENT ON COLUMN keplersc.kdifis.folio_marbe IS 'Folio Marbete';
COMMENT ON COLUMN keplersc.kdifis.costo_invent_sis IS 'Costo inventario sistema';
COMMENT ON COLUMN keplersc.kdifis.costo_invent_real IS 'Costo inventario real';
COMMENT ON COLUMN keplersc.kdifis.cantidad_sis IS 'Cantidad en sistema';
COMMENT ON COLUMN keplersc.kdifis.c9 IS 'Diferencia Existencia';
COMMENT ON COLUMN keplersc.kdifis.c8 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdifis.c7 IS 'Costo Promedio Real';
COMMENT ON COLUMN keplersc.kdifis.c6 IS 'Existencia Real';
COMMENT ON COLUMN keplersc.kdifis.c5 IS 'Referencia';
COMMENT ON COLUMN keplersc.kdifis.c4 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdifis.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdifis.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdifis.c10 IS 'Diferencia Valor Inventario';
COMMENT ON COLUMN keplersc.kdifis.c1 IS 'Sucursal';

