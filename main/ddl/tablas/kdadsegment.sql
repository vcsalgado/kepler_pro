CREATE  TABLE keplersc.kdadsegment (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdadsegment ADD CONSTRAINT pk_kdadsegment PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdadsegment IS 'Adendas Segmento';
COMMENT ON COLUMN keplersc.kdadsegment.c3 IS 'Descripcion del Segmento';
COMMENT ON COLUMN keplersc.kdadsegment.c2 IS 'Clave Segmento';
COMMENT ON COLUMN keplersc.kdadsegment.c1 IS 'Clave Adenda';

