CREATE  TABLE keplersc.kdcatcuest (
  tipo_actividad character varying(4) NOT NULL,
  clave character varying(7) NOT NULL,
  descripcion character varying NOT NULL,
  status character varying(2) NOT NULL,
  orden integer NOT NULL DEFAULT 0,
  posicion character varying(10) NOT NULL DEFAULT 'UNICO'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatcuest ADD CONSTRAINT kdcatcuest_pk PRIMARY KEY (tipo_actividad, clave);
COMMENT ON TABLE keplersc.kdcatcuest IS 'Catalogo preguntas cuestionarios';
COMMENT ON COLUMN keplersc.kdcatcuest.tipo_actividad IS 'Tipo de Actividad';
COMMENT ON COLUMN keplersc.kdcatcuest.status IS 'Estatus pregunta';
COMMENT ON COLUMN keplersc.kdcatcuest.posicion IS 'Grupo de pregunta';
COMMENT ON COLUMN keplersc.kdcatcuest.orden IS 'Orden de presentacion de pregunta';
COMMENT ON COLUMN keplersc.kdcatcuest.descripcion IS 'Pregunta';
COMMENT ON COLUMN keplersc.kdcatcuest.clave IS 'Clave pregunta';

