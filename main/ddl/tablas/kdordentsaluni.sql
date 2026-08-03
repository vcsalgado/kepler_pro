CREATE  TABLE keplersc.kdordentsaluni (
  sucursal character varying(7) NOT NULL,
  tipo character varying(1) NOT NULL,
  orden character varying(10) NOT NULL,
  fecha_sal timestamp without time zone NULL,
  km_sal numeric NULL,
  usr_salida character varying(10) NULL,
  fec_reg_sal timestamp without time zone NULL,
  motivo_sal character varying(300) NULL,
  fecha_ent timestamp without time zone NULL,
  km_ent numeric NULL,
  usr_ent character varying(10) NULL,
  fec_reg_ent timestamp without time zone NULL,
  comentarios character varying(300) NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdordentsaluni IS 'Tabla para el registro de unidades que salen y regresan al taller.';
COMMENT ON COLUMN keplersc.kdordentsaluni.usr_salida IS 'Usuario que registra la salida.';
COMMENT ON COLUMN keplersc.kdordentsaluni.usr_ent IS 'Usuario que registra el regreso.';
COMMENT ON COLUMN keplersc.kdordentsaluni.tipo IS 'Tipo de orden.';
COMMENT ON COLUMN keplersc.kdordentsaluni.sucursal IS 'Sucursal de la unidad.';
COMMENT ON COLUMN keplersc.kdordentsaluni.orden IS 'Número de orden.';
COMMENT ON COLUMN keplersc.kdordentsaluni.motivo_sal IS 'Motivo por el que sale la unidad.';
COMMENT ON COLUMN keplersc.kdordentsaluni.km_sal IS 'Kilometraje al momento de la salida.';
COMMENT ON COLUMN keplersc.kdordentsaluni.km_ent IS 'Kilometraje al momento de regreso.';
COMMENT ON COLUMN keplersc.kdordentsaluni.fecha_sal IS 'Fecha y hora en que salió la unidad.';
COMMENT ON COLUMN keplersc.kdordentsaluni.fecha_ent IS 'Fecha y hora en que regresa la unidad al taller.';
COMMENT ON COLUMN keplersc.kdordentsaluni.fec_reg_sal IS 'Fecha en sistema de registro de la salida.';
COMMENT ON COLUMN keplersc.kdordentsaluni.fec_reg_ent IS 'Fecha de registro del regreso.';
COMMENT ON COLUMN keplersc.kdordentsaluni.comentarios IS 'Comentarios adicionales.';

