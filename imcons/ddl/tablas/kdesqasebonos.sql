CREATE  TABLE keplersc.kdesqasebonos (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric(5,2) NOT NULL DEFAULT 0,
  c3 numeric(10,5) NOT NULL DEFAULT 0,
  c4 numeric(5,2) NOT NULL DEFAULT 0,
  c5 numeric(10,5) NOT NULL DEFAULT 0,
  c6 numeric(5,2) NOT NULL DEFAULT 0,
  c7 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdesqasebonos ADD CONSTRAINT pk_kdesqasebonos PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdesqasebonos IS 'Bonos asesor';
COMMENT ON COLUMN keplersc.kdesqasebonos.c7 IS 'Porcentaje sobre utilidad bruta total';
COMMENT ON COLUMN keplersc.kdesqasebonos.c6 IS 'Alcance de capacitacion';
COMMENT ON COLUMN keplersc.kdesqasebonos.c5 IS 'Porcentaje sobre la utilidad bruta total';
COMMENT ON COLUMN keplersc.kdesqasebonos.c4 IS 'Objetivo manejo de procedimientos';
COMMENT ON COLUMN keplersc.kdesqasebonos.c3 IS 'Porcentaje sobre utilidad bruta';
COMMENT ON COLUMN keplersc.kdesqasebonos.c2 IS 'Objetivo de CSI';
COMMENT ON COLUMN keplersc.kdesqasebonos.c1 IS 'Llave';

