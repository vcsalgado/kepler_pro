CREATE  TABLE keplersc.kdtiemposnd (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 numeric(6,3) NOT NULL DEFAULT 0,
  c5 character varying(2) NOT NULL DEFAULT ''::character varying,
  c6 character varying(4) NOT NULL DEFAULT ''::character varying,
  c7 character varying(30) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtiemposnd ADD CONSTRAINT pk_kdtiemposnd PRIMARY KEY (c1, c3);
CREATE INDEX IF NOT EXISTS sindkdtiemposnd02 ON keplersc.kdtiemposnd USING btree (c3, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtiemposnd03 ON keplersc.kdtiemposnd USING btree (c6, c5, c3, c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdtiemposnd04 ON keplersc.kdtiemposnd USING btree (c8, c3, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdtiemposnd.c8 IS 'Eliminar';
COMMENT ON COLUMN keplersc.kdtiemposnd.c7 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdtiemposnd.c6 IS 'Anio';
COMMENT ON COLUMN keplersc.kdtiemposnd.c5 IS 'Mes';
COMMENT ON COLUMN keplersc.kdtiemposnd.c4 IS 'TiempoNoDisponible';
COMMENT ON COLUMN keplersc.kdtiemposnd.c3 IS 'FechaNoDisponible';
COMMENT ON COLUMN keplersc.kdtiemposnd.c2 IS 'TipoOperario';
COMMENT ON COLUMN keplersc.kdtiemposnd.c1 IS 'Operario';

