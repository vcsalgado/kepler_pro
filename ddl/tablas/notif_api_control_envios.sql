CREATE  TABLE keplersc.notif_api_control_envios (
  id_transaccion integer NOT NULL,
  api_id character varying(50) NOT NULL,
  datos_interfaz character varying(300) NOT NULL,
  fecha_envio timestamp without time zone NULL,
  resultado character varying(3) NULL,
  estatus character varying(1) NOT NULL DEFAULT 'P'::character varying,
  descripcion_resultado character varying(300) NULL,
  accion character varying(10) NULL,
  fecha_registro timestamp without time zone NOT NULL DEFAULT now(),
  oem character varying(10) NULL,
  CONSTRAINT notif_api_control_envios_unique UNIQUE (id_transaccion)
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.notif_api_control_envios IS 'Registro de envios de notificaciones';
COMMENT ON COLUMN keplersc.notif_api_control_envios.resultado IS 'Ok - Correcto; Err - Error';
COMMENT ON COLUMN keplersc.notif_api_control_envios.oem IS 'Identificador OEM de la planta';
COMMENT ON COLUMN keplersc.notif_api_control_envios.id_transaccion IS 'Consecutivo de transaccion';
COMMENT ON COLUMN keplersc.notif_api_control_envios.fecha_registro IS 'Fecha de registro de notificacion';
COMMENT ON COLUMN keplersc.notif_api_control_envios.fecha_envio IS 'Fecha de envio de notificacion';
COMMENT ON COLUMN keplersc.notif_api_control_envios.estatus IS 'P-endiente; E-n proceso; T-erminado';
COMMENT ON COLUMN keplersc.notif_api_control_envios.descripcion_resultado IS 'Descripcion de resultado';
COMMENT ON COLUMN keplersc.notif_api_control_envios.datos_interfaz IS 'Datos interfaz';
COMMENT ON COLUMN keplersc.notif_api_control_envios.api_id IS 'Identificador de API';
COMMENT ON COLUMN keplersc.notif_api_control_envios.accion IS 'Siguiente accion';

