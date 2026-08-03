CREATE  TABLE keplersc.kdtmktresult (
  resultado_id numeric NOT NULL,
  descripcion character varying NOT NULL,
  seleccionable character varying NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktresult ADD CONSTRAINT kdtmktresult_pk PRIMARY KEY (resultado_id);
COMMENT ON TABLE keplersc.kdtmktresult IS 'resultados de los contactos tmkt';
COMMENT ON COLUMN keplersc.kdtmktresult.seleccionable IS 'Resultado selecionable desde tmkt';

