CREATE  TABLE keplersc.horario_nodisp_taller (
  sucursal character varying NOT NULL DEFAULT ''::character varying,
  fecha date NOT NULL DEFAULT '1800-01-01'::date,
  horario_nodisp_inicio character varying NOT NULL DEFAULT ''::character varying,
  horario_nodisp_fin character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS horario_nodisp_taller_sucursal_idx ON keplersc.horario_nodisp_taller USING btree (sucursal, fecha) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.horario_nodisp_taller IS 'Horarios no disponibles del taller de servicio';

