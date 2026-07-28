CREATE  TABLE keplersc.param_opc_usr_sec (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  opcion character varying(35) NOT NULL DEFAULT ''::character varying,
  usuario character varying(21) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.param_opc_usr_sec IS 'Parametros Opciones Usuarios';
COMMENT ON COLUMN keplersc.param_opc_usr_sec.usuario IS 'Usuario con Acceso';
COMMENT ON COLUMN keplersc.param_opc_usr_sec.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.param_opc_usr_sec.opcion IS 'Parametro Opcion / Funcionalidad';

