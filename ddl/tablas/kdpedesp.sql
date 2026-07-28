CREATE  TABLE keplersc.kdpedesp (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(18) NOT NULL DEFAULT ''::character varying,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(7) NOT NULL DEFAULT ''::character varying,
  c15 character varying(40) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 numeric NOT NULL DEFAULT 0,
  c19 numeric NOT NULL DEFAULT 0,
  c20 character varying(10) NOT NULL DEFAULT ''::character varying,
  c21 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c22 character varying(17) NOT NULL DEFAULT ''::character varying,
  c23 numeric NOT NULL DEFAULT 0,
  c24 character varying(7) NOT NULL DEFAULT ''::character varying,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 character varying(10) NOT NULL DEFAULT ''::character varying,
  c27 character varying(5) NOT NULL DEFAULT ''::character varying,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 numeric NOT NULL DEFAULT 0,
  c31 numeric NOT NULL DEFAULT 0,
  c32 character varying(7) NOT NULL DEFAULT ''::character varying,
  c33 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c34 character varying(40) NOT NULL DEFAULT ''::character varying,
  c35 character varying(40) NOT NULL DEFAULT ''::character varying,
  c36 character varying(40) NOT NULL DEFAULT ''::character varying,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedesp ADD CONSTRAINT pk_kdpedesp PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
CREATE INDEX IF NOT EXISTS sindkdpedesp02 ON keplersc.kdpedesp USING btree (c1, c13, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedesp03 ON keplersc.kdpedesp USING btree (c14, c15, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedesp04 ON keplersc.kdpedesp USING btree (c1, c8, c9, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedesp05 ON keplersc.kdpedesp USING btree (c1, c11, c12) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedesp06 ON keplersc.kdpedesp USING btree (c1, c23, c22, c8) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdpedesp07 ON keplersc.kdpedesp USING btree (c1, c28, c29, c30, c31, c32, c9) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpedesp IS 'Pedidos especiales';
COMMENT ON COLUMN keplersc.kdpedesp.c9 IS 'Producto';
COMMENT ON COLUMN keplersc.kdpedesp.c8 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdpedesp.c7 IS 'Partida';
COMMENT ON COLUMN keplersc.kdpedesp.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdpedesp.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdpedesp.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdpedesp.c34 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdpedesp.c33 IS 'Fecha Venta';
COMMENT ON COLUMN keplersc.kdpedesp.c32 IS 'Folio';
COMMENT ON COLUMN keplersc.kdpedesp.c31 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdpedesp.c30 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdpedesp.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdpedesp.c29 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdpedesp.c28 IS 'Genero Venta';
COMMENT ON COLUMN keplersc.kdpedesp.c27 IS 'Motivo Cancelación';
COMMENT ON COLUMN keplersc.kdpedesp.c26 IS 'Folio';
COMMENT ON COLUMN keplersc.kdpedesp.c25 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdpedesp.c24 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdpedesp.c23 IS 'Aplica Servicio';
COMMENT ON COLUMN keplersc.kdpedesp.c22 IS 'Serie VIN';
COMMENT ON COLUMN keplersc.kdpedesp.c21 IS 'Fecha Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c20 IS 'Folio Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdpedesp.c19 IS 'Tipo Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c17 IS 'Naturaleza Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c16 IS 'Genero Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c15 IS 'Referencia Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c14 IS 'Sucursal Pedido';
COMMENT ON COLUMN keplersc.kdpedesp.c13 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdpedesp.c12 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdpedesp.c11 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdpedesp.c10 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdpedesp.c1 IS 'Sucursal';

