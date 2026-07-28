CREATE  TABLE keplersc.kddinv (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT ''::character varying,
  c4 character varying(3) NOT NULL DEFAULT ''::character varying,
  c5 character varying(2) NOT NULL DEFAULT ''::character varying,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kddinv ADD CONSTRAINT pk_kddinv PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kddinv IS 'Inventario Autos';
COMMENT ON COLUMN keplersc.kddinv.c7 IS 'Nuevo o Usado';
COMMENT ON COLUMN keplersc.kddinv.c6 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kddinv.c5 IS 'Digitos del Modelo';
COMMENT ON COLUMN keplersc.kddinv.c4 IS 'Digitos de Identificacion';
COMMENT ON COLUMN keplersc.kddinv.c3 IS 'Año Modelo';
COMMENT ON COLUMN keplersc.kddinv.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kddinv.c1 IS 'Clave';

