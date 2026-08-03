CREATE  TABLE keplersc.kdvenprov (
  c1 character varying(16) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(50) NOT NULL DEFAULT ''::character varying,
  c4 character varying(50) NOT NULL DEFAULT ''::character varying,
  c5 character varying(30) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvenprov ADD CONSTRAINT pk_kdvenprov PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdvenprov IS 'Cuentas proveedor';
COMMENT ON COLUMN keplersc.kdvenprov.c6 IS 'RFC';
COMMENT ON COLUMN keplersc.kdvenprov.c5 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdvenprov.c4 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdvenprov.c3 IS 'Direccion';
COMMENT ON COLUMN keplersc.kdvenprov.c2 IS 'Nombre del proveedor';
COMMENT ON COLUMN keplersc.kdvenprov.c1 IS 'Cuenta Contable';

