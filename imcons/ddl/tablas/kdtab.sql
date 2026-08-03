CREATE  TABLE keplersc.kdtab (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 character varying(70) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtab ADD CONSTRAINT pk_kdtab PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdtab.c5 IS 'Horas';
COMMENT ON COLUMN keplersc.kdtab.c4 IS 'Descripción de la Operación';
COMMENT ON COLUMN keplersc.kdtab.c3 IS 'Clave';
COMMENT ON COLUMN keplersc.kdtab.c2 IS 'Vehículo';
COMMENT ON COLUMN keplersc.kdtab.c1 IS 'Marca';

