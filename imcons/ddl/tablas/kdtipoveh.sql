CREATE  TABLE keplersc.kdtipoveh (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtipoveh ADD CONSTRAINT pk_kdtipoveh PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdtipoveh IS 'Tipo Autos';
COMMENT ON COLUMN keplersc.kdtipoveh.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdtipoveh.c1 IS 'Clave';

