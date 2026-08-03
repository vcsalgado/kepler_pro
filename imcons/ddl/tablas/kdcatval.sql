CREATE  TABLE keplersc.kdcatval (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatval ADD CONSTRAINT pk_kdcatval PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdcatval.c3 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdcatval.c2 IS 'Nombre del Valuador';
COMMENT ON COLUMN keplersc.kdcatval.c1 IS 'Clave del Valuador';

