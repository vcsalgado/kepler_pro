CREATE  TABLE keplersc.kdrefreq (
  c1 character varying(7) NOT NULL,
  c2 character varying(18) NOT NULL,
  c3 timestamp without time zone NOT NULL,
  c4 character varying(1) NOT NULL,
  c5 character varying(1) NOT NULL,
  c6 numeric NOT NULL,
  c7 numeric NOT NULL,
  c8 character varying(7) NOT NULL,
  c9 numeric NULL,
  c10 numeric(10,2) NULL,
  c11 numeric(10,2) NULL,
  c12 numeric NOT NULL,
  c13 numeric NULL,
  c14 character varying(1) NULL,
  c15 character varying(1) NULL,
  c16 character varying(1) NULL,
  c17 character varying(1) NULL,
  c18 numeric NULL,
  c19 numeric NULL,
  c20 character varying(7) NULL,
  c21 character varying(1) NULL,
  c22 timestamp without time zone NOT NULL,
  c23 numeric NULL,
  c24 character varying(18) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdrefreq ADD CONSTRAINT kdrefreq_pk PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8, c12);
CREATE UNIQUE INDEX IF NOT EXISTS kdrefreq_c1_idx ON keplersc.kdrefreq USING btree (c1, c2, c12) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdrefreq_c2_idx ON keplersc.kdrefreq USING btree (c1, c15, c16, c17, c18, c19, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdrefreq_c3_idx ON keplersc.kdrefreq USING btree (c1, c22, c23, c2, c12) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdrefreq_c4_idx ON keplersc.kdrefreq USING btree (c1, c24, c3, c4, c5, c6, c7, c8, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdrefreq_c5_idx ON keplersc.kdrefreq USING btree (c1, c13, c12, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdrefreq IS 'Pedidos de refacciones';
COMMENT ON COLUMN keplersc.kdrefreq.c9 IS 'Partida';
COMMENT ON COLUMN keplersc.kdrefreq.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdrefreq.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdrefreq.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdrefreq.c5 IS 'Naturaleaza';
COMMENT ON COLUMN keplersc.kdrefreq.c4 IS 'Genero';
COMMENT ON COLUMN keplersc.kdrefreq.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdrefreq.c24 IS 'Numero Original';
COMMENT ON COLUMN keplersc.kdrefreq.c23 IS 'Numero Pedido';
COMMENT ON COLUMN keplersc.kdrefreq.c22 IS 'Fecha Pedido';
COMMENT ON COLUMN keplersc.kdrefreq.c20 IS 'Folio Compra';
COMMENT ON COLUMN keplersc.kdrefreq.c2 IS 'Producto';
COMMENT ON COLUMN keplersc.kdrefreq.c19 IS 'Tipo Compra';
COMMENT ON COLUMN keplersc.kdrefreq.c18 IS 'Grupo Compra';
COMMENT ON COLUMN keplersc.kdrefreq.c17 IS 'Naturaleza Compra';
COMMENT ON COLUMN keplersc.kdrefreq.c16 IS 'Genero Compra';
COMMENT ON COLUMN keplersc.kdrefreq.c13 IS 'Activo 0-Activo, 2-Activo';
COMMENT ON COLUMN keplersc.kdrefreq.c12 IS 'Estatus 0-Pedir, 1-Pedido, 2-Surtido';
COMMENT ON COLUMN keplersc.kdrefreq.c11 IS 'Unitario';
COMMENT ON COLUMN keplersc.kdrefreq.c10 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdrefreq.c1 IS 'Sucursal';

