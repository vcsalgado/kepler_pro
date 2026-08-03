CREATE  TABLE keplersc.ifz_bp_horario_asesor (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  cve_asesor character varying(20) NOT NULL DEFAULT ''::character varying,
  dia integer NOT NULL DEFAULT 0,
  id_asesor_dia integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_horario_asesor_unique UNIQUE (id_asesor_dia)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_horario_asesor ADD CONSTRAINT ifz_bp_horario_asesor_pk PRIMARY KEY (sucursal, cve_asesor, dia);
COMMENT ON TABLE keplersc.ifz_bp_horario_asesor IS 'Tabla intermedia Horario Asesor Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_horario_asesor.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_horario_asesor.id_asesor_dia IS 'Id Asesor y dia de trabajo en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_horario_asesor.dia IS '1=Lunes, 2=Martes, 3=Miercoles, 4=Jueves, 5=Viernes, 6=Sabado';
COMMENT ON COLUMN keplersc.ifz_bp_horario_asesor.cve_asesor IS 'Clave del Asesor';

