CREATE  TABLE keplersc.mig_k75_sub_call (
  modulo character varying(20) NOT NULL,
  funcion character varying(40) NOT NULL,
  tree_call character varying(300) NOT NULL DEFAULT ''::character varying,
  estatus character varying(1) NOT NULL DEFAULT 'P'::character varying,
  comentarios character varying(300) NOT NULL DEFAULT ''::character varying,
  last_modulo_call character varying(20) NOT NULL DEFAULT ''::character varying,
  last_funcion_call character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.mig_k75_sub_call ADD CONSTRAINT mig_k75_sub_call_pk PRIMARY KEY (modulo, funcion, tree_call);
COMMENT ON COLUMN keplersc.mig_k75_sub_call.last_modulo_call IS 'Ultimo modulo invocado';
COMMENT ON COLUMN keplersc.mig_k75_sub_call.last_funcion_call IS 'Ultima funcion llamada';
COMMENT ON COLUMN keplersc.mig_k75_sub_call.estatus IS '[P]endiente; [M]igrado; [N]o Aplica; por [R]esolver';
COMMENT ON COLUMN keplersc.mig_k75_sub_call.comentarios IS 'Comentarios seguimiento';

