CREATE  TABLE keplersc.kdordenbitabierta (
  sucursal character varying(7) NOT NULL,
  tipo character varying(1) NOT NULL,
  orden character varying(10) NOT NULL,
  fec_hora_reg timestamp without time zone NULL,
  usr character varying(15) NULL,
  actividad character varying(300) NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdordenbitabierta IS 'Tabla para el registro-bitacota por orden.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.usr IS 'Usuario que registra.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.tipo IS 'Tipo de orden.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.sucursal IS 'Sucursal.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.orden IS 'Número de orden.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.fec_hora_reg IS 'Fecha y hora del registro.';
COMMENT ON COLUMN keplersc.kdordenbitabierta.actividad IS 'Actividad.';

