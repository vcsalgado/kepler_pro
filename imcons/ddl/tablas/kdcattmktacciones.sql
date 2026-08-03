CREATE  TABLE keplersc.kdcattmktacciones (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcattmktacciones ADD CONSTRAINT pk_kdcattmktacciones PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcattmktacciones02 ON keplersc.kdcattmktacciones USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcattmktacciones IS 'Catalogo de acciones TMKT';
COMMENT ON COLUMN keplersc.kdcattmktacciones.c3 IS 'Tipo 10 Recontactar, 20 No recont, 40 Realizo cita, 50 Vino sin cita';
COMMENT ON COLUMN keplersc.kdcattmktacciones.c2 IS 'Accion';
COMMENT ON COLUMN keplersc.kdcattmktacciones.c1 IS 'Clave';

