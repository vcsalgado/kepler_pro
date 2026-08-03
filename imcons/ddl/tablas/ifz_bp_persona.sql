CREATE  TABLE keplersc.ifz_bp_persona (
  cve_cliente character varying(7) NOT NULL DEFAULT ''::character varying,
  id_persona integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_persona_unique UNIQUE (id_persona)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_persona ADD CONSTRAINT ifz_bp_persona_pk PRIMARY KEY (cve_cliente);
COMMENT ON TABLE keplersc.ifz_bp_persona IS 'Tabla intermedia personas Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_persona.id_persona IS 'Id de la persona en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_persona.cve_cliente IS 'Clave Cliente kdud.c2';

