CREATE  TABLE keplersc.ser_ra_archivos (
  sucursal character varying(5) NOT NULL DEFAULT ''::character varying,
  vin character varying(18) NOT NULL DEFAULT ''::character varying,
  consecutivo numeric NOT NULL DEFAULT 0,
  ruta character varying NOT NULL DEFAULT ''::character varying,
  tipo character varying NOT NULL DEFAULT ''::character varying,
  ultima_actualizacion timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.ser_ra_archivos IS 'Imagenes Recepcion Activa';
COMMENT ON COLUMN keplersc.ser_ra_archivos.vin IS 'Vin';
COMMENT ON COLUMN keplersc.ser_ra_archivos.ultima_actualizacion IS 'Ultima actualizacion';
COMMENT ON COLUMN keplersc.ser_ra_archivos.tipo IS 'Tipo';
COMMENT ON COLUMN keplersc.ser_ra_archivos.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ser_ra_archivos.ruta IS 'Ruta';
COMMENT ON COLUMN keplersc.ser_ra_archivos.consecutivo IS 'Consecutivo';

