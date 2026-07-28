CREATE  TABLE keplersc.kdcfdconfig (
  c1 character varying(7) NOT NULL DEFAULT 0,
  c2 character varying(13) NOT NULL DEFAULT ''::character varying,
  c3 character varying(80) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(80) NULL,
  c6 timestamp without time zone NULL,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcfdconfig ADD CONSTRAINT pk_kdcfdconfig PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdcfdconfig IS 'CFD Configuracion';
COMMENT ON COLUMN keplersc.kdcfdconfig.c7 IS 'Numero de concesionario';
COMMENT ON COLUMN keplersc.kdcfdconfig.c6 IS 'Fecha nueva regeneracion = Fecha implementacion';
COMMENT ON COLUMN keplersc.kdcfdconfig.c5 IS 'Ruta archivo PLD';
COMMENT ON COLUMN keplersc.kdcfdconfig.c4 IS '0=Fec Actual 1=Ultimo dia mes anterior';
COMMENT ON COLUMN keplersc.kdcfdconfig.c3 IS 'RutaDestinoIntercambio';
COMMENT ON COLUMN keplersc.kdcfdconfig.c2 IS 'RfcEmisor';
COMMENT ON COLUMN keplersc.kdcfdconfig.c1 IS 'IdConfiguracion (Sucursal)';

