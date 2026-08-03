CREATE  TABLE keplersc.param_oper (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  parametro character varying(35) NOT NULL DEFAULT ''::character varying,
  valor character varying(35) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_param_oper ON keplersc.param_oper USING btree (sucursal, parametro) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.param_oper IS 'Parametros Operativos';
COMMENT ON COLUMN keplersc.param_oper.valor IS 'Valor del Parametro';
COMMENT ON COLUMN keplersc.param_oper.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.param_oper.parametro IS 'Nombre del Parametro';

