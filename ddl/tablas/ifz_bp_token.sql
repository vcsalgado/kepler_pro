CREATE  TABLE keplersc.ifz_bp_token (
  sucursal character varying(20) NOT NULL DEFAULT ''::character varying,
  bptoken character varying(1500) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_token ADD CONSTRAINT id_reg_token_pkey PRIMARY KEY (sucursal);

