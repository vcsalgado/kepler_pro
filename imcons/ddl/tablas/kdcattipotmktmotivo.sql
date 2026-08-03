CREATE  TABLE keplersc.kdcattipotmktmotivo (
  clave character varying(5) NOT NULL,
  descripcion character varying NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcattipotmktmotivo ADD CONSTRAINT kd_cat_tipo_tmkt_motivo_pk PRIMARY KEY (clave);

