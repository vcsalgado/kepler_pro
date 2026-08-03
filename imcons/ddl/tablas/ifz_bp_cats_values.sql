CREATE  TABLE keplersc.ifz_bp_cats_values (
  id_cat integer NOT NULL,
  cve_val character varying(100) NOT NULL,
  dscr_val character varying(150) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_cats_values ADD CONSTRAINT ifz_bp_cats_values_pk PRIMARY KEY (id_cat, cve_val);

