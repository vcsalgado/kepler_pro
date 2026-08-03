CREATE  TABLE keplersc.mig_datos_rectificacion (
  tabla character varying(25) NOT NULL,
  depurar character varying(1) NOT NULL DEFAULT 'N'::character varying,
  refol character varying(1) NOT NULL DEFAULT 'N'::character varying,
  colgen character varying(4) NOT NULL DEFAULT ''::character varying,
  colnat character varying(4) NOT NULL DEFAULT ''::character varying,
  colgpo character varying(4) NOT NULL DEFAULT ''::character varying,
  coltipo character varying(4) NOT NULL DEFAULT ''::character varying,
  colfolio character varying(4) NOT NULL DEFAULT ''::character varying,
  colsucursal character varying(4) NOT NULL DEFAULT ''::character varying,
  auditada character varying NOT NULL DEFAULT 'N'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.mig_datos_rectificacion ADD CONSTRAINT mig_datos_rectificacion_pk PRIMARY KEY (tabla);
COMMENT ON TABLE keplersc.mig_datos_rectificacion IS 'Acciones sobre tablas';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.tabla IS 'Nombre de la tabla';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.refol IS 'Indica si se debe regenerar folio en la tabla';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.depurar IS 'Indica si se eliminan datos de la tabla ';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.coltipo IS 'Columna tipo';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.colsucursal IS 'Columna sucursal';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.colnat IS 'Columna naturaleza';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.colgpo IS 'Columna grupo';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.colgen IS 'Columna genero';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.colfolio IS 'Columna folio';
COMMENT ON COLUMN keplersc.mig_datos_rectificacion.auditada IS 'Tabla analizada';

