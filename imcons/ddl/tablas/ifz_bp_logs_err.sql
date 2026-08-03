CREATE  TABLE keplersc.ifz_bp_logs_err (
  fecha timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  archivo character varying(100) NOT NULL DEFAULT ''::character varying,
  mensaje character varying(1500) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_logs_err ADD CONSTRAINT id_reg_log_err_pkey PRIMARY KEY (fecha);

