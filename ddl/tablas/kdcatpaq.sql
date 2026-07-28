CREATE  TABLE keplersc.kdcatpaq (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(5) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatpaq ADD CONSTRAINT pk_kdcatpaq PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdcatpaq02 ON keplersc.kdcatpaq USING btree (c3, c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatpaq IS 'Catalogo de paquetes';
COMMENT ON COLUMN keplersc.kdcatpaq.c4 IS 'Clasificacion horas';
COMMENT ON COLUMN keplersc.kdcatpaq.c3 IS 'Clasificacion paquete';
COMMENT ON COLUMN keplersc.kdcatpaq.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcatpaq.c1 IS 'Clave del paquete';

