CREATE  TABLE keplersc.kdvargv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(30) NOT NULL DEFAULT ''::character varying,
  c8 numeric(5,2) NOT NULL DEFAULT 0,
  c9 numeric(6,2) NOT NULL DEFAULT 0,
  c10 numeric(6,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvargv ADD CONSTRAINT pk_kdvargv PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdvargv IS 'Objetivos Variables Coach';
COMMENT ON COLUMN keplersc.kdvargv.c9 IS 'Objetivo';
COMMENT ON COLUMN keplersc.kdvargv.c8 IS 'Porcentaje Comision';
COMMENT ON COLUMN keplersc.kdvargv.c7 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdvargv.c6 IS '(N)uevo (S)eminuevo';
COMMENT ON COLUMN keplersc.kdvargv.c5 IS '1';
COMMENT ON COLUMN keplersc.kdvargv.c4 IS 'Anio';
COMMENT ON COLUMN keplersc.kdvargv.c3 IS 'Mes';
COMMENT ON COLUMN keplersc.kdvargv.c2 IS 'Esquema';
COMMENT ON COLUMN keplersc.kdvargv.c10 IS 'Resultado';
COMMENT ON COLUMN keplersc.kdvargv.c1 IS 'Sucursal';

