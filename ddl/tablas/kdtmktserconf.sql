CREATE  TABLE keplersc.kdtmktserconf (
  c1 character varying(7) NOT NULL DEFAULT 0,
  c2 character varying NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric NOT NULL DEFAULT 0,
  c17 numeric NOT NULL DEFAULT 0,
  c18 numeric NOT NULL DEFAULT 0,
  c19 character varying(50) NOT NULL DEFAULT ''::character varying,
  c20 numeric NOT NULL DEFAULT 1,
  c21 numeric NOT NULL DEFAULT 3,
  c22 numeric NOT NULL DEFAULT 2,
  c23 numeric NOT NULL DEFAULT 1,
  c24 numeric NOT NULL DEFAULT 0,
  c25 numeric NOT NULL DEFAULT 0,
  c26 numeric NOT NULL DEFAULT 1,
  c27 character varying NOT NULL DEFAULT 0,
  c28 numeric NOT NULL DEFAULT 2,
  col_suc_ventas character varying(7) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktserconf ADD CONSTRAINT pk_kdtmktserconf PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdtmktserconf IS 'Configuracion de Telemarketing de Servicios';
COMMENT ON COLUMN keplersc.kdtmktserconf.c9 IS 'Numero de dias para items para historial';
COMMENT ON COLUMN keplersc.kdtmktserconf.c8 IS 'Tipo de historial 10 Compacto; 20 Detallado';
COMMENT ON COLUMN keplersc.kdtmktserconf.c7 IS 'Dias de margen para llegada del vehiculo vs cita';
COMMENT ON COLUMN keplersc.kdtmktserconf.c6 IS 'Fecha de ultima rutina de TMKT';
COMMENT ON COLUMN keplersc.kdtmktserconf.c5 IS 'Dias de recontacto para servicio';
COMMENT ON COLUMN keplersc.kdtmktserconf.c4 IS 'Dias de recontacto para ventas';
COMMENT ON COLUMN keplersc.kdtmktserconf.c3 IS 'km recorridos para siguiente cita';
COMMENT ON COLUMN keplersc.kdtmktserconf.c28 IS 'Recordatorio posterior 3 (debe ser mayor a recordatorio posterior 2)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c27 IS 'Telefono Centro de Servicio';
COMMENT ON COLUMN keplersc.kdtmktserconf.c26 IS 'Recordatorio posterior 2 (debe ser mayor a recordatorio posterior 1)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c25 IS 'Recordatorio posterior 1 (si hay cambios agregar a kd_tipo_n )';
COMMENT ON COLUMN keplersc.kdtmktserconf.c24 IS 'Recordatorio anterior 4 (debe ser menor a recordatorio anterior 3)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c23 IS 'Recordatorio anterior 3 (debe ser menor a recordatorio anterior 2)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c22 IS 'Recordatorio anterior 2 (debe ser menor a recordatorio anterior 1)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c21 IS 'Recordatorio anterior 1 (si hay cambios agregar a kd_tipo_n )';
COMMENT ON COLUMN keplersc.kdtmktserconf.c20 IS 'Dias para contacto Urgente (N-U) (debe ser mayor a c4 y c5)';
COMMENT ON COLUMN keplersc.kdtmktserconf.c2 IS 'Marca';
COMMENT ON COLUMN keplersc.kdtmktserconf.c19 IS 'Ruta de archivo';
COMMENT ON COLUMN keplersc.kdtmktserconf.c18 IS 'Importar archivo de carga';
COMMENT ON COLUMN keplersc.kdtmktserconf.c17 IS 'Numero maximo de operaciones nuevas en fila de ventas';
COMMENT ON COLUMN keplersc.kdtmktserconf.c16 IS 'Numero maximo de operaciones nuevas en fila de servicio';
COMMENT ON COLUMN keplersc.kdtmktserconf.c15 IS 'Numero maximo de recontactos permitidos por dia';
COMMENT ON COLUMN keplersc.kdtmktserconf.c14 IS 'Limite superior para ser considerado inactivo';
COMMENT ON COLUMN keplersc.kdtmktserconf.c13 IS 'Limite inferior para ser considerado inactivo';
COMMENT ON COLUMN keplersc.kdtmktserconf.c12 IS 'Numero de items para recomendaciones';
COMMENT ON COLUMN keplersc.kdtmktserconf.c11 IS 'Numero de items para historial';
COMMENT ON COLUMN keplersc.kdtmktserconf.c10 IS 'Numero de dias para items para recomendaciones';
COMMENT ON COLUMN keplersc.kdtmktserconf.c1 IS 'Sucursal';

