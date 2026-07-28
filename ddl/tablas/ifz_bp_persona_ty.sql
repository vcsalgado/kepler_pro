CREATE  TABLE keplersc.ifz_bp_persona_ty (
  cve_cliente character varying(7) NOT NULL DEFAULT ''::character varying,
  tipo_cliente character varying(2) NOT NULL DEFAULT ''::character varying,
  serie character varying(30) NOT NULL DEFAULT ''::character varying,
  id_persona integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_persona_ty_unique UNIQUE (id_persona)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_persona_ty ADD CONSTRAINT ifz_bp_persona_ty_pk PRIMARY KEY (cve_cliente, tipo_cliente, serie);
COMMENT ON TABLE keplersc.ifz_bp_persona_ty IS 'Tabla intermedia personas Interface TY-BP';
COMMENT ON COLUMN keplersc.ifz_bp_persona_ty.tipo_cliente IS 'Tipo de Persona Armados de kdud [P, H] y kdserie [C, M]';
COMMENT ON COLUMN keplersc.ifz_bp_persona_ty.serie IS 'Serie Vehiculo kdserie.c4';
COMMENT ON COLUMN keplersc.ifz_bp_persona_ty.id_persona IS 'Id de la persona en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_persona_ty.cve_cliente IS 'Clave Cliente kdud.c2';

