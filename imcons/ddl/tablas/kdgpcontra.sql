CREATE  TABLE keplersc.kdgpcontra (
  sucursal_id character varying(2) NOT NULL,
  proveedor_id character varying(7) NOT NULL,
  grupo_id integer NOT NULL,
  fecha_registro timestamp without time zone NOT NULL DEFAULT now(),
  descripcion character varying(100) NOT NULL,
  importe_asignado numeric(12,2) NULL DEFAULT 0,
  importe_comprobado numeric(12,2) NOT NULL DEFAULT 0,
  estatus character varying(1) NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgpcontra ADD CONSTRAINT kdgpcontra_pk PRIMARY KEY (sucursal_id, grupo_id);
COMMENT ON TABLE keplersc.kdgpcontra IS 'Grupos de contrarecibos';
COMMENT ON COLUMN keplersc.kdgpcontra.sucursal_id IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdgpcontra.proveedor_id IS 'Id Proveedor';
COMMENT ON COLUMN keplersc.kdgpcontra.importe_comprobado IS 'Importe comprobado';
COMMENT ON COLUMN keplersc.kdgpcontra.importe_asignado IS 'Importe asignado al grupo';
COMMENT ON COLUMN keplersc.kdgpcontra.grupo_id IS 'Consecutivo identoficador de grupo';
COMMENT ON COLUMN keplersc.kdgpcontra.fecha_registro IS 'Fecha de alta del registro';
COMMENT ON COLUMN keplersc.kdgpcontra.estatus IS 'Estatus del grupo [A]bierto / [C] Cerrado';
COMMENT ON COLUMN keplersc.kdgpcontra.descripcion IS 'Descripcion del grupo';

