CREATE  TABLE keplersc.ser_ra_recepcion_activa (
  sucursal character varying(5) NOT NULL DEFAULT ''::character varying,
  vin character varying(18) NOT NULL DEFAULT ''::character varying,
  consecutivo numeric NOT NULL DEFAULT 0,
  tipo_orden character varying NOT NULL DEFAULT ''::character varying,
  orden character varying NOT NULL DEFAULT ''::character varying,
  folio_cita character varying NOT NULL DEFAULT '0'::character varying,
  fecha timestamp without time zone NOT NULL DEFAULT now()
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ser_ra_recepcion_activa ADD CONSTRAINT ser_ra_recepcion_activa_pkey PRIMARY KEY (consecutivo);
COMMENT ON TABLE keplersc.ser_ra_recepcion_activa IS 'Recepcion activa';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.vin IS 'Vin';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.tipo_orden IS 'Tipo_orden';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.orden IS 'Orden';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.folio_cita IS 'folio_cita';
COMMENT ON COLUMN keplersc.ser_ra_recepcion_activa.consecutivo IS 'Consecutivo';

