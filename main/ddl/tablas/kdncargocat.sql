CREATE  TABLE keplersc.kdncargocat (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(300) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdncargocat ADD CONSTRAINT pk_kdncargocat PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdncargocat.c4 IS 'Unidad';
COMMENT ON COLUMN keplersc.kdncargocat.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdncargocat.c2 IS 'Clave del SAT';
COMMENT ON COLUMN keplersc.kdncargocat.c1 IS 'Clave del Cargo';

