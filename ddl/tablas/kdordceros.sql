CREATE  TABLE keplersc.kdordceros (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(21) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 character varying(100) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordceros ADD CONSTRAINT pk_kdordceros PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdordceros02 ON keplersc.kdordceros USING btree (c1, c5, c2, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdordceros IS 'Ordenes cerradas en cero';
COMMENT ON COLUMN keplersc.kdordceros.c6 IS 'Motivo';
COMMENT ON COLUMN keplersc.kdordceros.c5 IS 'Fecha';
COMMENT ON COLUMN keplersc.kdordceros.c4 IS 'Usuario';
COMMENT ON COLUMN keplersc.kdordceros.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdordceros.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdordceros.c1 IS 'Sucursal';
CREATE TRIGGER kdordceros_notif AFTER INSERT ON keplersc.kdordceros FOR EACH ROW EXECUTE FUNCTION keplersc.notif_registrar_movto();

