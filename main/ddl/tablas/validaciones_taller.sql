CREATE  TABLE keplersc.validaciones_taller (
  sucursal character varying(2) NOT NULL DEFAULT ''::character varying,
  validacion character varying NOT NULL DEFAULT ''::character varying,
  parametros character varying NOT NULL DEFAULT ''::character varying,
  activa boolean[] NULL,
  num_val character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS validaciones_taller_sucursal_idx ON keplersc.validaciones_taller USING btree (sucursal, validacion) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.validaciones_taller IS 'validaciones taller';
COMMENT ON COLUMN keplersc.validaciones_taller.parametros IS 'horas(parametro < 12)
cortes(param1=hora corte de hoy, param2=hora corte de mañana)';

