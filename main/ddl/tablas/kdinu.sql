CREATE  TABLE keplersc.kdinu (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinu ADD CONSTRAINT pk_kdinu PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdinu IS 'Unidades';
COMMENT ON COLUMN keplersc.kdinu.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdinu.c1 IS 'Clave unidad';

