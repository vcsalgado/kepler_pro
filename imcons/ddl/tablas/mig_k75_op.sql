CREATE  TABLE keplersc.mig_k75_op (
  id_prog character varying(8) NOT NULL,
  descripcion character varying(30) NULL,
  id_unidad character varying(1) NULL,
  estatus character varying(1) NULL,
  comentarios character varying NULL,
  desarrolladores character varying NULL,
  probadores character varying NULL,
  inicio_mig date NULL,
  fin_mig date NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.mig_k75_op ADD CONSTRAINT mig_k75_op_pk PRIMARY KEY (id_prog);
COMMENT ON TABLE keplersc.mig_k75_op IS 'Programas K75';
COMMENT ON COLUMN keplersc.mig_k75_op.probadores IS 'Probadores de opcion';
COMMENT ON COLUMN keplersc.mig_k75_op.inicio_mig IS 'Inicio de migracion';
COMMENT ON COLUMN keplersc.mig_k75_op.id_unidad IS 'Unidad de negocio Ventas; Servicio; Refacciones';
COMMENT ON COLUMN keplersc.mig_k75_op.id_prog IS 'Nombre programa k75';
COMMENT ON COLUMN keplersc.mig_k75_op.fin_mig IS 'fin_mig';
COMMENT ON COLUMN keplersc.mig_k75_op.estatus IS 'Pendiente; Desarrollo; pRuebas; Migrado; rEsolver;Correcion';
COMMENT ON COLUMN keplersc.mig_k75_op.descripcion IS 'Nombre de la opcion en menu';
COMMENT ON COLUMN keplersc.mig_k75_op.desarrolladores IS 'Desarrolladores de opcion';
COMMENT ON COLUMN keplersc.mig_k75_op.comentarios IS 'Comentarios de seguimiento';

