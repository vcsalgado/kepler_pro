CREATE  TABLE keplersc.kdusraccess (
  c1 character varying(21) NOT NULL DEFAULT ''::character varying,
  c2 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c3 character varying(8) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(12) NOT NULL DEFAULT ''::character varying,
  c10 character varying(50) NOT NULL DEFAULT ''::character varying,
  c11 character varying(2000) NULL,
  fecha_registro timestamp without time zone NULL DEFAULT now()
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusraccess03 ON keplersc.kdusraccess USING btree (c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdusraccess02 ON keplersc.kdusraccess USING btree (c4, c5, c6, c7, c8, c9, c2, c3) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdusraccess.fecha_registro IS 'Fecha y hora de registreo de operacion';
COMMENT ON COLUMN keplersc.kdusraccess.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdusraccess.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdusraccess.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdusraccess.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdusraccess.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdusraccess.c4 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdusraccess.c3 IS 'Hora';
COMMENT ON COLUMN keplersc.kdusraccess.c2 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdusraccess.c11 IS 'Detalle de proceso';
COMMENT ON COLUMN keplersc.kdusraccess.c10 IS 'Tipo Movimiento';
COMMENT ON COLUMN keplersc.kdusraccess.c1 IS 'Usuario';

