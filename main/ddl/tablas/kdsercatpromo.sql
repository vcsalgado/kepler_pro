CREATE  TABLE keplersc.kdsercatpromo (
  clave character varying(7) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(30) NOT NULL DEFAULT ''::character varying,
  fecha_inicial timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  fecha_final timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsercatpromo IS 'Catálogo de promociones de citas y ordenes';
COMMENT ON COLUMN keplersc.kdsercatpromo.fecha_inicial IS 'Fecha inicio de vigencia de promocion';
COMMENT ON COLUMN keplersc.kdsercatpromo.fecha_final IS 'Fecha de fin de vigencia de promocion';
COMMENT ON COLUMN keplersc.kdsercatpromo.descripcion IS 'Descripcion de promocion';
COMMENT ON COLUMN keplersc.kdsercatpromo.clave IS 'Clave de promocion';

