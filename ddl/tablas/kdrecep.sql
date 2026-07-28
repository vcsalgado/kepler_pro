CREATE  TABLE keplersc.kdrecep (
  c1 character varying(6) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 character varying(40) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(10) NOT NULL DEFAULT ''::character varying,
  c8 character varying(40) NOT NULL DEFAULT ''::character varying,
  c9 character varying(40) NOT NULL DEFAULT ''::character varying,
  c10 character varying(40) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(21) NOT NULL DEFAULT ''::character varying,
  c13 character varying(7) NOT NULL DEFAULT ''::character varying,
  c14 numeric NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric NOT NULL DEFAULT 0,
  c17 numeric NOT NULL DEFAULT 0,
  c18 character varying(10) NOT NULL DEFAULT ''::character varying,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(5) NOT NULL DEFAULT ''::character varying,
  c21 numeric NOT NULL DEFAULT 0,
  col_cita_en_linea character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdrecep ADD CONSTRAINT pk_kdrecep PRIMARY KEY (c1);
CREATE INDEX IF NOT EXISTS sindkdrecep02 ON keplersc.kdrecep USING btree (c12) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdrecep03 ON keplersc.kdrecep USING btree (c11, c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdrecep.col_cita_en_linea IS 'S o N';
COMMENT ON COLUMN keplersc.kdrecep.c9 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdrecep.c8 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdrecep.c7 IS 'Telefono oficina';
COMMENT ON COLUMN keplersc.kdrecep.c6 IS 'Telefono movil oficina';
COMMENT ON COLUMN keplersc.kdrecep.c5 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdrecep.c4 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdrecep.c3 IS 'Direccion';
COMMENT ON COLUMN keplersc.kdrecep.c21 IS 'Clave esquema por utilidad';
COMMENT ON COLUMN keplersc.kdrecep.c20 IS 'Ext oficina';
COMMENT ON COLUMN keplersc.kdrecep.c2 IS 'Nombre del recepcionista';
COMMENT ON COLUMN keplersc.kdrecep.c19 IS 'Telefono movil personal';
COMMENT ON COLUMN keplersc.kdrecep.c18 IS 'Telefono casa';
COMMENT ON COLUMN keplersc.kdrecep.c17 IS 'Final segundo horario de citas';
COMMENT ON COLUMN keplersc.kdrecep.c16 IS 'Inicio segundo horario de citas';
COMMENT ON COLUMN keplersc.kdrecep.c15 IS 'Final primer horario de citas';
COMMENT ON COLUMN keplersc.kdrecep.c14 IS 'Inicio primer horario de citas';
COMMENT ON COLUMN keplersc.kdrecep.c13 IS 'Clave de esquema';
COMMENT ON COLUMN keplersc.kdrecep.c12 IS 'Usuario Correspondiente';
COMMENT ON COLUMN keplersc.kdrecep.c11 IS 'Activo';
COMMENT ON COLUMN keplersc.kdrecep.c10 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdrecep.c1 IS 'Clave';

