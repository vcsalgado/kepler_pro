CREATE  TABLE keplersc.conf_mensajes (
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  medio_contacto character varying NOT NULL DEFAULT ''::character varying,
  identificador_proceso character varying NOT NULL DEFAULT ''::character varying,
  tipo_n character varying NOT NULL DEFAULT ''::character varying,
  template character varying NOT NULL DEFAULT ''::character varying,
  contenido1 character varying NOT NULL DEFAULT ''::character varying,
  contenido2 character varying NOT NULL DEFAULT ''::character varying,
  contenido3 character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS conf_mensajes_sucursal_idx ON keplersc.conf_mensajes USING btree (sucursal, medio_contacto, identificador_proceso, tipo_n) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.conf_mensajes.tipo_n IS 'kd_tipo_n';
COMMENT ON COLUMN keplersc.conf_mensajes.sucursal IS 'kdms';
COMMENT ON COLUMN keplersc.conf_mensajes.medio_contacto IS 'kdmediocontacto';
COMMENT ON COLUMN keplersc.conf_mensajes.identificador_proceso IS 'kd_ident_proceso';

