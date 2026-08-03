CREATE  TABLE keplersc.mig_k75_sub (
  modulo character varying(20) NOT NULL,
  funcion character varying(40) NOT NULL,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying,
  estatus character varying(1) NOT NULL DEFAULT ''::character varying,
  nombre_destino character varying(100) NOT NULL DEFAULT ''::character varying,
  comentarios character varying(500) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.mig_k75_sub ADD CONSTRAINT migracion_k75_sub_pk PRIMARY KEY (modulo, funcion);
COMMENT ON TABLE keplersc.mig_k75_sub IS 'Funciones K75';
COMMENT ON COLUMN keplersc.mig_k75_sub.nombre_destino IS 'Nombre del programa destino';
COMMENT ON COLUMN keplersc.mig_k75_sub.modulo IS 'Nombre del programa en K75';
COMMENT ON COLUMN keplersc.mig_k75_sub.funcion IS 'Nombre de la funcion';
COMMENT ON COLUMN keplersc.mig_k75_sub.estatus IS 'Estado de migracion: [P]endiente; [M]igrado; por [R]esolver; [N]o aplica';
COMMENT ON COLUMN keplersc.mig_k75_sub.comentarios IS 'Comentarios seguimiento';

