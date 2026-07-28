CREATE  TABLE keplersc.kdgpcontra (
  grupo_id integer NOT NULL,
  fecha_registo timestamp without time zone NOT NULL DEFAULT now(),
  descripcion character varying(100) NOT NULL,
  importe_asignado numeric(12,2) NULL,
  sucursal_id character varying(2) NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdgpcontra IS 'Grupos de contrarecibos';
COMMENT ON COLUMN keplersc.kdgpcontra.sucursal_id IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdgpcontra.importe_asignado IS 'Importe asignado al grupo';
COMMENT ON COLUMN keplersc.kdgpcontra.grupo_id IS 'Consecutivo identoficador de grupo';
COMMENT ON COLUMN keplersc.kdgpcontra.fecha_registo IS 'Fecha de alta del registro';
COMMENT ON COLUMN keplersc.kdgpcontra.descripcion IS 'Descripcion del grupo';

