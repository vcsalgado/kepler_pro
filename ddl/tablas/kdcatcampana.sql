CREATE  TABLE keplersc.kdcatcampana (
  c1 character varying(30) NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying,
  fecha_inicio timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone,
  fecha_fin timestamp without time zone NOT NULL DEFAULT '1900-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatcampana ADD CONSTRAINT pk_kdcatcampana PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdcatcampana IS 'Catalogo de Campanas de servicio';
COMMENT ON COLUMN keplersc.kdcatcampana.fecha_inicio IS 'Fecha Inicio de Campa?a';
COMMENT ON COLUMN keplersc.kdcatcampana.fecha_fin IS 'Fecha Fin de Campa?a';
COMMENT ON COLUMN keplersc.kdcatcampana.c2 IS 'Campana';
COMMENT ON COLUMN keplersc.kdcatcampana.c1 IS 'Clave';

