CREATE  TABLE keplersc.kdtsusp (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtsusp ADD CONSTRAINT pk_kdtsusp PRIMARY KEY (c1, c2, c3, c4, c5);
CREATE INDEX IF NOT EXISTS sindkdtsusp02 ON keplersc.kdtsusp USING btree (c1, c5, c6, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtsusp03 ON keplersc.kdtsusp USING btree (c1, c11, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtsusp04 ON keplersc.kdtsusp USING btree (c1, c6, c9, c2, c3, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtsusp05 ON keplersc.kdtsusp USING btree (c1, c11, c6, c2, c3, c4, c5) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtsusp.c9 IS 'Fecha de finalizacion de suspension';
COMMENT ON COLUMN keplersc.kdtsusp.c8 IS 'Hora de inicio de suspension';
COMMENT ON COLUMN keplersc.kdtsusp.c7 IS 'Fecha de inicio de suspension';
COMMENT ON COLUMN keplersc.kdtsusp.c6 IS 'Tipo de Suspension';
COMMENT ON COLUMN keplersc.kdtsusp.c5 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdtsusp.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdtsusp.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdtsusp.c2 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdtsusp.c11 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdtsusp.c10 IS 'Hora de finalizacion de suspension';
COMMENT ON COLUMN keplersc.kdtsusp.c1 IS 'Sucursal';

