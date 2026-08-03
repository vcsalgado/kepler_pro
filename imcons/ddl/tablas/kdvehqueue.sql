CREATE  TABLE keplersc.kdvehqueue (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(8) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvehqueue ADD CONSTRAINT pk_kdvehqueue PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdvehqueue02 ON keplersc.kdvehqueue USING btree (c2, c7, c5, c3, c4, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvehqueue03 ON keplersc.kdvehqueue USING btree (c8, c7, c5, c3, c4, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvehqueue04 ON keplersc.kdvehqueue USING btree (c1, c8) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvehqueue.c9 IS 'Clasificación Vehículo';
COMMENT ON COLUMN keplersc.kdvehqueue.c8 IS 'Operario';
COMMENT ON COLUMN keplersc.kdvehqueue.c7 IS 'Cita';
COMMENT ON COLUMN keplersc.kdvehqueue.c6 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdvehqueue.c5 IS 'Prioridad';
COMMENT ON COLUMN keplersc.kdvehqueue.c4 IS 'Hora';
COMMENT ON COLUMN keplersc.kdvehqueue.c3 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdvehqueue.c2 IS 'Clasificacion Operacion, S en caso indefinido';
COMMENT ON COLUMN keplersc.kdvehqueue.c11 IS 'Ubicación';
COMMENT ON COLUMN keplersc.kdvehqueue.c10 IS 'Clave del Recepcionista';
COMMENT ON COLUMN keplersc.kdvehqueue.c1 IS 'VIN';

