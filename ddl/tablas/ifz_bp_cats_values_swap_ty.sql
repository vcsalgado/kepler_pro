CREATE  TABLE keplersc.ifz_bp_cats_values_swap_ty (
  id_cat integer NOT NULL,
  cve_val character varying(100) NOT NULL,
  dscr_val character varying(150) NULL,
  id_suc integer NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_cats_values_swap_ty ADD CONSTRAINT ifz_bp_cats_values_swap_ty_pk PRIMARY KEY (id_cat, cve_val, id_suc);
COMMENT ON TABLE keplersc.ifz_bp_cats_values_swap_ty IS 'Tabla Swap Datos CATs para Armonizar Interface TY-BP';
COMMENT ON COLUMN keplersc.ifz_bp_cats_values_swap_ty.id_suc IS 'ID Sucursal BP';

