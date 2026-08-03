CREATE  TABLE keplersc.horario_taller (
  sucursal character varying(2) NOT NULL DEFAULT ''::character varying,
  dia character varying NOT NULL DEFAULT ''::character varying,
  recepcion_inicio character varying NOT NULL DEFAULT ''::character varying,
  recepcion_fin character varying NOT NULL DEFAULT ''::character varying,
  num_dia integer NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS horario_taller_sucursal_idx ON keplersc.horario_taller USING btree (sucursal, dia) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.horario_taller IS 'Horario de recepcion de taller';

