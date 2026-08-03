CREATE  TABLE keplersc.conte_cnt_grpdr (
  cuenta character varying(20) NOT NULL,
  codigo_agrupador character varying(10) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.conte_cnt_grpdr ADD CONSTRAINT conte_cnt_grpdr_pkey PRIMARY KEY (cuenta);
ALTER TABLE ONLY keplersc.conte_cnt_grpdr ADD CONSTRAINT conte_cnt_grpdr_codigo_agrupador_fkey FOREIGN KEY (codigo_agrupador) REFERENCES keplersc.conte_cat_cdg_grpdr(codigo_agrupador) ON DELETE RESTRICT;


