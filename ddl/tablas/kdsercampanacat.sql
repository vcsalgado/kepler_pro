CREATE  TABLE keplersc.kdsercampanacat (
  clave_campana character varying(10) NOT NULL,
  descripcion character varying NULL DEFAULT ''::character varying,
  notas character varying NULL DEFAULT ''::character varying,
  comentarios_cliente character varying NULL DEFAULT ''::character varying,
  url_boletines character varying NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsercampanacat ADD CONSTRAINT kdsercampanacat_pkey PRIMARY KEY (clave_campana);
COMMENT ON TABLE keplersc.kdsercampanacat IS 'Catalogo de campanas';
COMMENT ON COLUMN keplersc.kdsercampanacat.url_boletines IS 'URL donde estan publicados los boletines';
COMMENT ON COLUMN keplersc.kdsercampanacat.notas IS 'Nota de la campana';
COMMENT ON COLUMN keplersc.kdsercampanacat.descripcion IS 'Descripcion de la campana';
COMMENT ON COLUMN keplersc.kdsercampanacat.comentarios_cliente IS 'Comentarios para el  cliente';
COMMENT ON COLUMN keplersc.kdsercampanacat.clave_campana IS 'Clave de campana';

