CREATE  TABLE keplersc.kdini (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(60) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(6) NOT NULL DEFAULT ''::character varying,
  c5 character varying(6) NOT NULL DEFAULT ''::character varying,
  c6 character varying(6) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(5) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 numeric(15,10) NOT NULL DEFAULT 0,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(5) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 numeric(10,5) NOT NULL DEFAULT 0,
  c22 numeric(10,5) NOT NULL DEFAULT 0,
  c23 character varying(1) NOT NULL DEFAULT ''::character varying,
  c24 numeric(10,5) NOT NULL DEFAULT 0,
  c25 character varying(1) NOT NULL DEFAULT ''::character varying,
  c26 numeric(5,2) NOT NULL DEFAULT 0,
  c27 numeric(5,2) NOT NULL DEFAULT 0,
  c28 numeric(5,2) NOT NULL DEFAULT 0,
  c29 numeric(5,2) NOT NULL DEFAULT 0,
  c30 numeric(5,2) NOT NULL DEFAULT 0,
  c31 numeric(5,2) NOT NULL DEFAULT 0,
  c32 character varying(5) NOT NULL DEFAULT ''::character varying,
  c33 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdini ADD CONSTRAINT pk_kdini PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdini02 ON keplersc.kdini USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini03 ON keplersc.kdini USING btree (c32, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini06 ON keplersc.kdini USING btree (c8, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini07 ON keplersc.kdini USING btree (c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini08 ON keplersc.kdini USING btree (c8, c9, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini04 ON keplersc.kdini USING btree (c5, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdini05 ON keplersc.kdini USING btree (c6, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdini IS 'REFACCIONES';
COMMENT ON COLUMN keplersc.kdini.c9 IS 'Subgrupo';
COMMENT ON COLUMN keplersc.kdini.c8 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdini.c6 IS 'Localizacion 3';
COMMENT ON COLUMN keplersc.kdini.c5 IS 'Localizacion 2';
COMMENT ON COLUMN keplersc.kdini.c4 IS 'Localizacion 1';
COMMENT ON COLUMN keplersc.kdini.c33 IS 'Clave SAT';
COMMENT ON COLUMN keplersc.kdini.c32 IS 'IdAgrupador';
COMMENT ON COLUMN keplersc.kdini.c31 IS 'Unidadess minimas pedido';
COMMENT ON COLUMN keplersc.kdini.c30 IS 'Dias stock seguridad';
COMMENT ON COLUMN keplersc.kdini.c29 IS 'Probabilidad existencia';
COMMENT ON COLUMN keplersc.kdini.c28 IS 'Maxima fluctuacion tiempo entrega';
COMMENT ON COLUMN keplersc.kdini.c27 IS 'Tiempo entrega';
COMMENT ON COLUMN keplersc.kdini.c26 IS 'Ciclo ordenamiento';
COMMENT ON COLUMN keplersc.kdini.c24 IS 'Backorder';
COMMENT ON COLUMN keplersc.kdini.c22 IS 'Nivel maximo existencia';
COMMENT ON COLUMN keplersc.kdini.c21 IS 'Nivel minimo existencia';
COMMENT ON COLUMN keplersc.kdini.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdini.c19 IS 'Unidad medida base';
COMMENT ON COLUMN keplersc.kdini.c16 IS 'Conversion precio';
COMMENT ON COLUMN keplersc.kdini.c14 IS 'Precio 4';
COMMENT ON COLUMN keplersc.kdini.c13 IS 'Precio 3';
COMMENT ON COLUMN keplersc.kdini.c12 IS 'Precio 2';
COMMENT ON COLUMN keplersc.kdini.c11 IS 'Precio';
COMMENT ON COLUMN keplersc.kdini.c1 IS 'Clave';

