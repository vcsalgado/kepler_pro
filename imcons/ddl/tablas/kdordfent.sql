CREATE  TABLE keplersc.kdordfent (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordfent ADD CONSTRAINT pk_kdordfent PRIMARY KEY (c1, c2, c3, c4, c5);
CREATE INDEX IF NOT EXISTS sindkdordfent02 ON keplersc.kdordfent USING btree (c1, c4, c5, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdordfent IS 'Entregas de Ordenes de Servicio';
COMMENT ON COLUMN keplersc.kdordfent.c5 IS 'Hora de Entrega';
COMMENT ON COLUMN keplersc.kdordfent.c4 IS 'Fecha de Entrega';
COMMENT ON COLUMN keplersc.kdordfent.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdordfent.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdordfent.c1 IS 'Sucursal';

