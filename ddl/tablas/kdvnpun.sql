CREATE  TABLE keplersc.kdvnpun (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(7) NOT NULL DEFAULT ''::character varying,
  c15 character varying(5) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 numeric(10,2) NOT NULL DEFAULT 0,
  c19 numeric(10,2) NOT NULL DEFAULT 0,
  c20 numeric(10,2) NOT NULL DEFAULT 0,
  c21 numeric(10,2) NOT NULL DEFAULT 0,
  c22 character varying(1) NOT NULL DEFAULT ''::character varying,
  c23 numeric(10,2) NOT NULL DEFAULT 0,
  c24 numeric(10,2) NOT NULL DEFAULT 0,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvnpun ADD CONSTRAINT pk_kdvnpun PRIMARY KEY (c1, c2, c3, c4, c11);
CREATE INDEX IF NOT EXISTS sindkdvnpun02 ON keplersc.kdvnpun USING btree (c1, c6, c7, c8, c9, c10, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun03 ON keplersc.kdvnpun USING btree (c1, c12, c2, c3, c4, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun04 ON keplersc.kdvnpun USING btree (c1, c13, c12, c2, c3, c4, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun05 ON keplersc.kdvnpun USING btree (c1, c13, c15, c12, c2, c3, c4, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun06 ON keplersc.kdvnpun USING btree (c1, c14, c13, c12, c2, c3, c4, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun07 ON keplersc.kdvnpun USING btree (c1, c5, c12, c2, c3, c4, c11) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvnpun08 ON keplersc.kdvnpun USING btree (c1, c14, c13, c15, c12, c2, c3, c4, c11) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdvnpun IS 'Puntos Venta';
COMMENT ON COLUMN keplersc.kdvnpun.c9 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvnpun.c8 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvnpun.c7 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvnpun.c6 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvnpun.c5 IS 'Alta=0; Baja=10';
COMMENT ON COLUMN keplersc.kdvnpun.c4 IS 'Partida';
COMMENT ON COLUMN keplersc.kdvnpun.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdvnpun.c24 IS 'Importe';
COMMENT ON COLUMN keplersc.kdvnpun.c23 IS 'IVA';
COMMENT ON COLUMN keplersc.kdvnpun.c21 IS 'Precio Cargos Varios';
COMMENT ON COLUMN keplersc.kdvnpun.c20 IS 'Precio TOTs';
COMMENT ON COLUMN keplersc.kdvnpun.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdvnpun.c19 IS 'Precio Refacciones';
COMMENT ON COLUMN keplersc.kdvnpun.c18 IS 'Precio M Obra';
COMMENT ON COLUMN keplersc.kdvnpun.c15 IS 'Paquete';
COMMENT ON COLUMN keplersc.kdvnpun.c14 IS 'Recepcionista';
COMMENT ON COLUMN keplersc.kdvnpun.c13 IS 'Tipo de Punto';
COMMENT ON COLUMN keplersc.kdvnpun.c12 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvnpun.c11 IS 'Punto';
COMMENT ON COLUMN keplersc.kdvnpun.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvnpun.c1 IS 'Sucursal';

