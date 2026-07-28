CREATE  TABLE keplersc.kdij (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(18) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(7) NOT NULL DEFAULT ''::character varying,
  c9 numeric NOT NULL DEFAULT 0,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 double precision NOT NULL DEFAULT 0,
  c12 character varying(3) NOT NULL DEFAULT ''::character varying,
  c13 numeric(15,2) NOT NULL DEFAULT 0,
  c14 numeric(15,2) NOT NULL DEFAULT 0,
  c15 character varying(7) NOT NULL DEFAULT ''::character varying,
  c16 character varying(5) NOT NULL DEFAULT ''::character varying,
  c17 double precision NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 character varying(20) NOT NULL DEFAULT ''::character varying,
  c20 character varying(5) NOT NULL DEFAULT ''::character varying,
  c21 double precision NOT NULL DEFAULT 0,
  c22 double precision NOT NULL DEFAULT 0,
  c23 character varying(10) NOT NULL DEFAULT ''::character varying,
  c24 character varying(10) NOT NULL DEFAULT ''::character varying,
  c25 double precision NOT NULL DEFAULT 0,
  c26 double precision NOT NULL DEFAULT 0,
  c27 double precision NOT NULL DEFAULT 0,
  c28 character varying(1) NOT NULL DEFAULT ''::character varying,
  c29 character varying(1) NOT NULL DEFAULT ''::character varying,
  c30 character varying(1) NOT NULL DEFAULT ''::character varying,
  c31 character varying(1) NOT NULL DEFAULT ''::character varying,
  c32 character varying(1) NOT NULL DEFAULT ''::character varying,
  c33 character varying(1) NOT NULL DEFAULT ''::character varying,
  c34 character varying(1) NOT NULL DEFAULT ''::character varying,
  c35 character varying(1) NOT NULL DEFAULT ''::character varying,
  c36 character varying(1) NOT NULL DEFAULT ''::character varying,
  c37 character varying(1) NOT NULL DEFAULT ''::character varying,
  c38 numeric NOT NULL DEFAULT 0,
  c39 numeric NOT NULL DEFAULT 0,
  c40 character varying(7) NOT NULL DEFAULT ''::character varying,
  c41 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdij ADD CONSTRAINT pk_kdij PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8, c9);
CREATE INDEX IF NOT EXISTS sindkdij02 ON keplersc.kdij USING btree (c1, c10, c2, c3, c4, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdij03 ON keplersc.kdij USING btree (c1, c3, c10, c2, c4, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdij04 ON keplersc.kdij USING btree (c1, c2, c3, c10, c4, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdij05 ON keplersc.kdij USING btree (c1, c4, c5, c6, c7, c8, c9, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdij06 ON keplersc.kdij USING btree (c3, c10, c1, c2, c4, c5, c6, c7, c8, c9) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdij.c9 IS 'Partida';
COMMENT ON COLUMN keplersc.kdij.c8 IS 'Folio';
COMMENT ON COLUMN keplersc.kdij.c7 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdij.c6 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdij.c5 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdij.c4 IS 'Genero';
COMMENT ON COLUMN keplersc.kdij.c3 IS 'Producto';
COMMENT ON COLUMN keplersc.kdij.c2 IS 'Almacen';
COMMENT ON COLUMN keplersc.kdij.c1 IS 'Sucursal';

