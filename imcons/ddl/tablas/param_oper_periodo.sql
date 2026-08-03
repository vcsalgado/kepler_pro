CREATE  TABLE keplersc.param_oper_periodo (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  mes character varying(2) NOT NULL DEFAULT ''::character varying,
  parametro character varying(35) NOT NULL DEFAULT ''::character varying,
  valor character varying(35) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.param_oper_periodo IS 'Parametros operativos por periodo';
COMMENT ON COLUMN keplersc.param_oper_periodo.valor IS 'Valor del parametro';
COMMENT ON COLUMN keplersc.param_oper_periodo.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.param_oper_periodo.parametro IS 'Nombre del parametro';
COMMENT ON COLUMN keplersc.param_oper_periodo.mes IS 'Mes';
COMMENT ON COLUMN keplersc.param_oper_periodo.anio IS 'A o';

