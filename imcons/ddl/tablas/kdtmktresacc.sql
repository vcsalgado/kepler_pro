CREATE  TABLE keplersc.kdtmktresacc (
  resultado_id numeric NOT NULL DEFAULT 0,
  accion_id numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtmktresacc IS 'Relacion resultados accion';
COMMENT ON COLUMN keplersc.kdtmktresacc.resultado_id IS 'Resultado del contacto';
COMMENT ON COLUMN keplersc.kdtmktresacc.accion_id IS 'Accion relacionada con el resultado';

