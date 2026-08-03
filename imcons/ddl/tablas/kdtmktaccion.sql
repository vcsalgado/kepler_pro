CREATE  TABLE keplersc.kdtmktaccion (
  accion_id numeric NOT NULL,
  descripcion character varying NOT NULL,
  crear_contacto character varying(1) NULL DEFAULT 'N'::character varying,
  crear_motivo numeric NULL,
  seleccionable character varying(1) NULL,
  estado character varying(5) NOT NULL DEFAULT 'NA'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktaccion ADD CONSTRAINT kdtmktaccion_pk PRIMARY KEY (accion_id);
ALTER TABLE ONLY keplersc.kdtmktaccion ADD CONSTRAINT kdtmktaccion_fk FOREIGN KEY (estado) REFERENCES keplersc.kdcatestadotmktaccion(clave) ON UPDATE RESTRICT ON DELETE RESTRICT;

COMMENT ON TABLE keplersc.kdtmktaccion IS 'acciones a tomar en los contactos de tmkt';
COMMENT ON COLUMN keplersc.kdtmktaccion.seleccionable IS 'Accion selecionabe desde tmkt';
COMMENT ON COLUMN keplersc.kdtmktaccion.descripcion IS 'Descripcion de la accion';
COMMENT ON COLUMN keplersc.kdtmktaccion.crear_motivo IS 'Motivo de contacto a crear, -1 mismo motivo del contacto original';
COMMENT ON COLUMN keplersc.kdtmktaccion.crear_contacto IS 'Indica Si crea o No un nuevo registro de contracto';
COMMENT ON COLUMN keplersc.kdtmktaccion.accion_id IS 'Identificador de la accion';

