CREATE  TABLE keplersc.job_whatsapp (
  job_whatsapp integer GENERATED ALWAYS AS IDENTITY NOT NULL,
  destinatarios character varying NOT NULL DEFAULT ''::character varying,
  mensaje character varying NOT NULL DEFAULT ''::character varying,
  archivos character varying NOT NULL DEFAULT ''::character varying,
  estatus character varying(2) NOT NULL DEFAULT ''::character varying,
  reintentos numeric NOT NULL DEFAULT 0,
  desc_error character varying NOT NULL DEFAULT ''::character varying,
  folio_tmkt character varying(10) NOT NULL DEFAULT ''::character varying,
  fecha_programacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  fecha_creacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  pais character varying NOT NULL DEFAULT ''::character varying,
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  imagen character varying NOT NULL DEFAULT ''::character varying,
  message_sid character varying NOT NULL DEFAULT ''::character varying,
  datos_asesor character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS job_whatsapp_job_whatsapp_idx ON keplersc.job_whatsapp USING btree (job_whatsapp) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.job_whatsapp IS 'mensajes de whatsapp';
COMMENT ON COLUMN keplersc.job_whatsapp.estatus IS '0 (pendiente), 10 (enviado) , 20 (error)';

