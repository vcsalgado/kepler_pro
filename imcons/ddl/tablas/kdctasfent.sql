CREATE  TABLE keplersc.kdctasfent (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctasfent ADD CONSTRAINT pk_kdctasfent PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdctasfent02 ON keplersc.kdctasfent USING btree (c1, c3, c4, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdctasfent IS 'Entregas de Citas de Servicio';
COMMENT ON COLUMN keplersc.kdctasfent.c4 IS 'Hora de Entrega';
COMMENT ON COLUMN keplersc.kdctasfent.c3 IS 'Fecha de Entrega';
COMMENT ON COLUMN keplersc.kdctasfent.c2 IS 'Folio de la Cita';
COMMENT ON COLUMN keplersc.kdctasfent.c1 IS 'Sucursal';

