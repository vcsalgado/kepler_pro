CREATE  TABLE keplersc.kd_tipo_n (
  c1 character varying NOT NULL DEFAULT ''::character varying,
  c2 character varying NOT NULL DEFAULT ''::character varying,
  c3 character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kd_tipo_n IS 'Tipos de N';
COMMENT ON COLUMN keplersc.kd_tipo_n.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kd_tipo_n.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kd_tipo_n.c1 IS 'Sucursal';

