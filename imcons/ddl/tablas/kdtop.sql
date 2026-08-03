CREATE  TABLE keplersc.kdtop (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(60) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtop ADD CONSTRAINT pk_kdtop PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdtop IS 'TIPO DE OPERACION';
COMMENT ON COLUMN keplersc.kdtop.c3 IS 'Operacion GMAC';
COMMENT ON COLUMN keplersc.kdtop.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtop.c1 IS 'Clave';

