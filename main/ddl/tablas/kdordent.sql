CREATE  TABLE keplersc.kdordent (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordent ADD CONSTRAINT pk_kdordent PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdordent02 ON keplersc.kdordent USING btree (c4, c5) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdordent IS 'Ordenes servicio control entrega';
COMMENT ON COLUMN keplersc.kdordent.c7 IS 'Hora promesa entrega original';
COMMENT ON COLUMN keplersc.kdordent.c6 IS 'Fecha promesa entrega original';
COMMENT ON COLUMN keplersc.kdordent.c5 IS 'Hora promesa entrega';
COMMENT ON COLUMN keplersc.kdordent.c4 IS 'Fecha promesa entrega';
COMMENT ON COLUMN keplersc.kdordent.c3 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdordent.c2 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdordent.c1 IS 'Surcursal';

