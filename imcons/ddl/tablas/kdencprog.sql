CREATE  TABLE keplersc.kdencprog (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 character varying(8) NOT NULL DEFAULT ''::character varying,
  c9 character varying(20) NOT NULL DEFAULT ''::character varying,
  c10 character varying(5) NOT NULL DEFAULT ''::character varying,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdencprog ADD CONSTRAINT pk_kdencprog PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdencprog02 ON keplersc.kdencprog USING btree (c6, c4, c5, c1, c2, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdencprog03 ON keplersc.kdencprog USING btree (c1, c11) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdencprog IS 'Encuestas programadas';
COMMENT ON COLUMN keplersc.kdencprog.c9 IS 'Usuario';
COMMENT ON COLUMN keplersc.kdencprog.c8 IS 'Hora';
COMMENT ON COLUMN keplersc.kdencprog.c7 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdencprog.c6 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdencprog.c5 IS 'Hora';
COMMENT ON COLUMN keplersc.kdencprog.c4 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdencprog.c3 IS 'Folio';
COMMENT ON COLUMN keplersc.kdencprog.c2 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdencprog.c11 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdencprog.c10 IS 'Encuesta';
COMMENT ON COLUMN keplersc.kdencprog.c1 IS 'Sucursal';

