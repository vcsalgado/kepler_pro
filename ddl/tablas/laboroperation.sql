CREATE  TABLE keplersc.laboroperation (
  id bigserial NOT NULL,
  id_grupo_vehiculo character varying(5) NOT NULL,
  id_vehiculo character varying(10) NULL,
  clave_operacion character varying(10) NULL,
  descripcion_operacion character varying(100) NULL,
  tiempo_asignado numeric(5,2) NULL,
  unidad_medida character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.laboroperation ADD CONSTRAINT laboroperation_pkey PRIMARY KEY (id);
COMMENT ON COLUMN keplersc.laboroperation.unidad_medida IS 'Unidad de medida de tiempo para la operación';
COMMENT ON COLUMN keplersc.laboroperation.tiempo_asignado IS 'Cantidad de tiempo para la operación';
COMMENT ON COLUMN keplersc.laboroperation.id_vehiculo IS 'Identificador del vehículo';
COMMENT ON COLUMN keplersc.laboroperation.id_grupo_vehiculo IS 'Identificador del grupo del vehículo';
COMMENT ON COLUMN keplersc.laboroperation.descripcion_operacion IS 'Descripción de la operación';
COMMENT ON COLUMN keplersc.laboroperation.clave_operacion IS 'Código de operación';

