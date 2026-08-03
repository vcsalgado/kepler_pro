CREATE  TABLE keplersc.conte_cat_cdg_grpdr (
  codigo_agrupador character varying(10) NOT NULL,
  descripcion character varying(160) NOT NULL,
  naturaleza character varying(1) NULL,
  nivel smallint NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.conte_cat_cdg_grpdr ADD CONSTRAINT conte_cat_cdg_grpdr_pk PRIMARY KEY (codigo_agrupador);

