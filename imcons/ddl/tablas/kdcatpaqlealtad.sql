CREATE  TABLE keplersc.kdcatpaqlealtad (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,5) NOT NULL DEFAULT 0,
  c3 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatpaqlealtad ADD CONSTRAINT pk_kdcatpaqlealtad PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdcatpaqlealtad.c3 IS 'Porcentaje descuento otras agencias';
COMMENT ON COLUMN keplersc.kdcatpaqlealtad.c2 IS 'Porcentaje descuento QM';
COMMENT ON COLUMN keplersc.kdcatpaqlealtad.c1 IS 'Clave del paquete';

