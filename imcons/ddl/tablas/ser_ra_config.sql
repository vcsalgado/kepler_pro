CREATE  TABLE keplersc.ser_ra_config (
  url character varying(150) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ser_ra_config ADD CONSTRAINT ser_ra_config_pkey PRIMARY KEY (url);
COMMENT ON TABLE keplersc.ser_ra_config IS 'Url Imagenes Recepcion Activa';
COMMENT ON COLUMN keplersc.ser_ra_config.url IS 'Url';

