CREATE  TABLE keplersc.kdvobjlinea (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 character varying(10) NOT NULL DEFAULT ''::character varying,
  c6 numeric(10,4) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvobjlinea ADD CONSTRAINT pk_kdvobjlinea PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdvobjlinea IS 'Ventas objetivos linea';
COMMENT ON COLUMN keplersc.kdvobjlinea.c6 IS 'Bono';
COMMENT ON COLUMN keplersc.kdvobjlinea.c5 IS 'Linea';
COMMENT ON COLUMN keplersc.kdvobjlinea.c4 IS 'Mes';
COMMENT ON COLUMN keplersc.kdvobjlinea.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdvobjlinea.c2 IS 'Esquema';
COMMENT ON COLUMN keplersc.kdvobjlinea.c1 IS 'Sucursal';

