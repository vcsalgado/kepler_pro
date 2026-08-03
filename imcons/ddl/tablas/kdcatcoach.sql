CREATE  TABLE keplersc.kdcatcoach (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(7) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatcoach ADD CONSTRAINT pk_kdcatcoach PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcatcoach01 ON keplersc.kdcatcoach USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatcoach02 ON keplersc.kdcatcoach USING btree (c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdcatcoach03 ON keplersc.kdcatcoach USING btree (c4, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatcoach IS 'Personal Coach';
COMMENT ON COLUMN keplersc.kdcatcoach.c6 IS 'Esquema comisiones';
COMMENT ON COLUMN keplersc.kdcatcoach.c5 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdcatcoach.c4 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdcatcoach.c3 IS 'Usuario';
COMMENT ON COLUMN keplersc.kdcatcoach.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdcatcoach.c1 IS 'Clave';

