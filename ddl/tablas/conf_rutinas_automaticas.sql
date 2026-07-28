CREATE  TABLE keplersc.conf_rutinas_automaticas (
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  sender_email character varying NOT NULL DEFAULT ''::character varying,
  sender_password character varying NOT NULL DEFAULT ''::character varying,
  twilio_account_sid character varying NOT NULL DEFAULT ''::character varying,
  twilio_auth_token character varying NOT NULL DEFAULT ''::character varying,
  sender_whatsapp character varying NOT NULL DEFAULT ''::character varying,
  sender_sms character varying NOT NULL DEFAULT ''::character varying,
  pspdfkit_api_key character varying NOT NULL DEFAULT ''::character varying,
  path_dir_virtual character varying NOT NULL DEFAULT ''::character varying,
  link_dir_virtual character varying NOT NULL DEFAULT ''::character varying,
  link_citas_en_linea character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.conf_rutinas_automaticas IS 'configuraciones para rutinas automaticas de Correos, Whatsapps y SMS';

