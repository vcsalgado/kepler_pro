CREATE  TABLE keplersc.kdtmktmotres (
  motivo_id numeric NOT NULL DEFAULT 0,
  resultado_id numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdtmktmotres IS 'Relacion motivo resultado de un contacto';
COMMENT ON COLUMN keplersc.kdtmktmotres.resultado_id IS 'Resultado relacionado con un motivo';
COMMENT ON COLUMN keplersc.kdtmktmotres.motivo_id IS 'Motivo de contacto';

