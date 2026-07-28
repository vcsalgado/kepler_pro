CREATE  TABLE keplersc.kdhorpag (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c12 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c13 character varying(6) NOT NULL DEFAULT ''::character varying,
  c14 numeric(10,6) NOT NULL DEFAULT 0,
  c15 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdhorpag ADD CONSTRAINT pk_kdhorpag PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdhorpag03 ON keplersc.kdhorpag USING btree (c1, c5, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdhorpag05 ON keplersc.kdhorpag USING btree (c1, c5, c13, c11, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdhorpag02 ON keplersc.kdhorpag USING btree (c1, c6, c7, c8, c9, c10, c2, c3, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdhorpag04 ON keplersc.kdhorpag USING btree (c1, c5, c12, c5, c6, c7, c8, c9, c10, c2, c3, c4) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdhorpag IS 'pago de horas por punto';
COMMENT ON COLUMN keplersc.kdhorpag.c9 IS 'Tpo';
COMMENT ON COLUMN keplersc.kdhorpag.c8 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdhorpag.c7 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdhorpag.c6 IS 'Género';
COMMENT ON COLUMN keplersc.kdhorpag.c5 IS 'Estado';
COMMENT ON COLUMN keplersc.kdhorpag.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdhorpag.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdhorpag.c2 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdhorpag.c15 IS 'Pago Total';
COMMENT ON COLUMN keplersc.kdhorpag.c14 IS 'Horas';
COMMENT ON COLUMN keplersc.kdhorpag.c13 IS 'Operario';
COMMENT ON COLUMN keplersc.kdhorpag.c12 IS 'Fecha de Pago';
COMMENT ON COLUMN keplersc.kdhorpag.c11 IS 'Fecha de Cierre';
COMMENT ON COLUMN keplersc.kdhorpag.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdhorpag.c1 IS 'Sucursal';

