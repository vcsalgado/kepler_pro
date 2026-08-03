CREATE  TABLE keplersc.kdordcuest (
  col_sucursal character varying(2) NOT NULL,
  col_tipo_actividad character varying(4) NOT NULL,
  col_tipo_orden character varying(1) NOT NULL,
  col_folio_orden character varying(10) NOT NULL,
  col_clave_actividad character varying(7) NOT NULL,
  col_descripcion character varying NOT NULL,
  col_resultado character varying(1) NOT NULL DEFAULT 'N'::character varying,
  col_comentario character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordcuest ADD CONSTRAINT kdordcuest_pk PRIMARY KEY (col_sucursal, col_tipo_actividad, col_tipo_orden, col_folio_orden, col_clave_actividad);
COMMENT ON TABLE keplersc.kdordcuest IS 'Cuestionarios de ordenes';
COMMENT ON COLUMN keplersc.kdordcuest.col_tipo_orden IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdordcuest.col_tipo_actividad IS 'Tipo de actividad';
COMMENT ON COLUMN keplersc.kdordcuest.col_sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdordcuest.col_resultado IS 'S o N';
COMMENT ON COLUMN keplersc.kdordcuest.col_folio_orden IS 'Numero de Orden';
COMMENT ON COLUMN keplersc.kdordcuest.col_descripcion IS 'Descripcion de la actividad';
COMMENT ON COLUMN keplersc.kdordcuest.col_comentario IS 'Comentario sobre la pregunta';
COMMENT ON COLUMN keplersc.kdordcuest.col_clave_actividad IS 'Clave de la actividad';

