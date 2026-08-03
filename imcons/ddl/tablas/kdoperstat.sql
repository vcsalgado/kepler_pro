CREATE  TABLE keplersc.kdoperstat (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(8) NOT NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(8) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdoperstat ADD CONSTRAINT pk_kdoperstat PRIMARY KEY (c1, c2, c3, c4, c5);
CREATE INDEX IF NOT EXISTS sindkdoperstat02 ON keplersc.kdoperstat USING btree (c1, c3, c2, c6, c7, c4, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoperstat03 ON keplersc.kdoperstat USING btree (c1, c4, c3, c2, c6, c7, c5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoperstat04 ON keplersc.kdoperstat USING btree (c1, c5, c2, c4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdoperstat05 ON keplersc.kdoperstat USING btree (c1, c4, c5, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdoperstat.c7 IS 'Hora de Ingreso';
COMMENT ON COLUMN keplersc.kdoperstat.c6 IS 'Fecha de Ingreso';
COMMENT ON COLUMN keplersc.kdoperstat.c5 IS 'Id de Unidad';
COMMENT ON COLUMN keplersc.kdoperstat.c4 IS 'Mecanico';
COMMENT ON COLUMN keplersc.kdoperstat.c3 IS 'Status';
COMMENT ON COLUMN keplersc.kdoperstat.c2 IS 'Tipo de Trabajo';
COMMENT ON COLUMN keplersc.kdoperstat.c1 IS 'Sucursal';

