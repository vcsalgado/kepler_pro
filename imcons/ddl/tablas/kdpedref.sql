CREATE  TABLE keplersc.kdpedref (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpedref ADD CONSTRAINT pk_kdpedref PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdpedref02 ON keplersc.kdpedref USING btree (c4, c1, c2) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdpedref IS 'Pedido sugerido formula';
COMMENT ON COLUMN keplersc.kdpedref.c5 IS 'Formula';
COMMENT ON COLUMN keplersc.kdpedref.c4 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdpedref.c3 IS 'Fecha referencia';
COMMENT ON COLUMN keplersc.kdpedref.c2 IS 'Referencia';
COMMENT ON COLUMN keplersc.kdpedref.c1 IS 'Sucursal';
CREATE TRIGGER kdpedref_notif AFTER INSERT OR DELETE OR UPDATE ON keplersc.kdpedref FOR EACH ROW EXECUTE FUNCTION keplersc.notif_registrar_movto();

