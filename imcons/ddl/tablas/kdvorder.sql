CREATE  TABLE keplersc.kdvorder (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(10) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 character varying(18) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 character varying(40) NOT NULL DEFAULT ''::character varying,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvorder ADD CONSTRAINT pk_kdvorder PRIMARY KEY (c1, c3, c4, c5, c7);
CREATE INDEX IF NOT EXISTS sindkdvorder02 ON keplersc.kdvorder USING btree (c1, c2, c3, c4, c5, c8, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder03 ON keplersc.kdvorder USING btree (c1, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder04 ON keplersc.kdvorder USING btree (c1, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder05 ON keplersc.kdvorder USING btree (c1, c10) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder06 ON keplersc.kdvorder USING btree (c1, c2, c3, c8, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder07 ON keplersc.kdvorder USING btree (c1, c11, c3, c4, c5, c8, c7) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvorder08 ON keplersc.kdvorder USING btree (c1, c2, c3, c4, c5, c10, c7) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvorder.c9 IS 'Número de Inventario';
COMMENT ON COLUMN keplersc.kdvorder.c8 IS 'Fecha Estimada de Entrega';
COMMENT ON COLUMN keplersc.kdvorder.c7 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdvorder.c6 IS 'Número de Serie';
COMMENT ON COLUMN keplersc.kdvorder.c5 IS 'Clave de Vestiduras';
COMMENT ON COLUMN keplersc.kdvorder.c4 IS 'Clave de Exteriores';
COMMENT ON COLUMN keplersc.kdvorder.c3 IS 'Clave';
COMMENT ON COLUMN keplersc.kdvorder.c2 IS 'Estatus de la Orden';
COMMENT ON COLUMN keplersc.kdvorder.c12 IS 'Concenso';
COMMENT ON COLUMN keplersc.kdvorder.c11 IS 'Fuera de Concenso';
COMMENT ON COLUMN keplersc.kdvorder.c10 IS 'Referencia o Número de Orden';
COMMENT ON COLUMN keplersc.kdvorder.c1 IS 'Sucursal';

