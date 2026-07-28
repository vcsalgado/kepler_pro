CREATE  TABLE keplersc.ifz_bp_horario_tecnico (
  sucursal character varying(7) NOT NULL DEFAULT ''::character varying,
  cve_tecnico character varying(20) NOT NULL DEFAULT ''::character varying,
  dia integer NOT NULL DEFAULT 0,
  id_tecnico_dia integer NOT NULL DEFAULT 0,
  CONSTRAINT ifz_bp_horario_tecnico_unique UNIQUE (id_tecnico_dia)
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_bp_horario_tecnico ADD CONSTRAINT ifz_bp_horario_tecnico_pk PRIMARY KEY (sucursal, cve_tecnico, dia);
COMMENT ON TABLE keplersc.ifz_bp_horario_tecnico IS 'Tabla intermedia Horario Tecnico Interface GM-BP';
COMMENT ON COLUMN keplersc.ifz_bp_horario_tecnico.sucursal IS 'Sucursal';
COMMENT ON COLUMN keplersc.ifz_bp_horario_tecnico.id_tecnico_dia IS 'Id Tecnico y dia de trabajo en bussinespro';
COMMENT ON COLUMN keplersc.ifz_bp_horario_tecnico.dia IS '1=Lunes, 2=Martes, 3=Miercoles, 4=Jueves, 5=Viernes, 6=Sabado';
COMMENT ON COLUMN keplersc.ifz_bp_horario_tecnico.cve_tecnico IS 'Clave del Tecnico';

