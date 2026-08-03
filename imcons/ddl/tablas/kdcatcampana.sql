CREATE  TABLE keplersc.kdcatcampana (
  c1 character varying(30) NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatcampana ADD CONSTRAINT pk_kdcatcampana PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdcatcampana IS 'Catalogo de Campanas de servicio';
COMMENT ON COLUMN keplersc.kdcatcampana.c2 IS 'Campana';
COMMENT ON COLUMN keplersc.kdcatcampana.c1 IS 'Clave';

