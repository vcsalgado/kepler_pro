CREATE  TABLE keplersc.job_sms (
  job_sms integer GENERATED ALWAYS AS IDENTITY NOT NULL,
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
  imagen character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS job_sms_job_sms_idx ON keplersc.job_sms USING btree (job_sms) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.job_sms IS 'mensajes de SMS';
COMMENT ON COLUMN keplersc.job_sms.estatus IS '0 pendiente, 10 enviado , 20 error';

