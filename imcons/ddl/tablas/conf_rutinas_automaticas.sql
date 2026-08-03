CREATE  TABLE keplersc.conf_rutinas_automaticas (
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  sender_email character varying NOT NULL DEFAULT ''::character varying,
  sender_password character varying NOT NULL DEFAULT ''::character varying,
  twilio_account_sid character varying NOT NULL DEFAULT ''::character varying,
  twilio_auth_token character varying NOT NULL DEFAULT ''::character varying,
  sender_whatsapp character varying NOT NULL DEFAULT ''::character varying,
  sender_sms character varying NOT NULL DEFAULT ''::character varying,
  path_dir_virtual character varying NOT NULL DEFAULT ''::character varying,
  link_dir_virtual character varying NOT NULL DEFAULT ''::character varying,
  smtp_server character varying NOT NULL DEFAULT ''::character varying,
  smtp_port character varying NOT NULL DEFAULT ''::character varying,
  link_citas_en_linea character varying NOT NULL DEFAULT ''::character varying,
  twilio_service_sid_wa character varying NOT NULL DEFAULT ''::character varying,
  twilio_content_sid_wa character varying NOT NULL DEFAULT ''::character varying,
  mostrar_kilometraje character varying(1) NOT NULL DEFAULT 'N'::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS conf_rutinas_automaticas_sucursal_idx ON keplersc.conf_rutinas_automaticas USING btree (sucursal) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.conf_rutinas_automaticas IS 'configuraciones para rutinas automaticas de Correos, Whatsapps y SMS';
COMMENT ON COLUMN keplersc.conf_rutinas_automaticas.mostrar_kilometraje IS 'S o N';

