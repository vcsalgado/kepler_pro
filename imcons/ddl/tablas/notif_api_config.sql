CREATE  TABLE keplersc.notif_api_config (
  oem character varying(10) NOT NULL,
  estatus character varying(1) NOT NULL,
  tipo_envio character varying(1) NOT NULL,
  url character varying(300) NOT NULL,
  descripcion character varying(50) NOT NULL,
  token character varying(100) NULL,
  api_id character varying(50) NOT NULL,
  CONSTRAINT notif_api_config_unique UNIQUE (oem, api_id)
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.notif_api_config IS 'Configuracion de APIS para notificacion de movtos a plantas';
COMMENT ON COLUMN keplersc.notif_api_config.url IS 'URL';
COMMENT ON COLUMN keplersc.notif_api_config.token IS 'Token';
COMMENT ON COLUMN keplersc.notif_api_config.tipo_envio IS 'P-ost G-et';
COMMENT ON COLUMN keplersc.notif_api_config.oem IS 'Identificador de marca';
COMMENT ON COLUMN keplersc.notif_api_config.estatus IS 'Estado de interfaz A-ctiva I-nactiva';
COMMENT ON COLUMN keplersc.notif_api_config.descripcion IS 'Descripcion';
COMMENT ON COLUMN keplersc.notif_api_config.api_id IS 'Identificador de la API';

