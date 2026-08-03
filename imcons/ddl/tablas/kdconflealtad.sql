CREATE  TABLE keplersc.kdconflealtad (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(7) NOT NULL DEFAULT ''::character varying,
  c3 numeric(10,5) NOT NULL DEFAULT 0,
  c4 numeric(10,5) NOT NULL DEFAULT 0,
  c5 numeric(10,5) NOT NULL DEFAULT 0,
  c6 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconflealtad ADD CONSTRAINT pk_kdconflealtad PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdconflealtad.c6 IS 'Porcentaje de Hojalateria para Otras';
COMMENT ON COLUMN keplersc.kdconflealtad.c5 IS 'Porcentaje de Hojalateria para QM';
COMMENT ON COLUMN keplersc.kdconflealtad.c4 IS 'Porcentaje de Falals para Otras';
COMMENT ON COLUMN keplersc.kdconflealtad.c3 IS 'Porcentaje de Fallas para QM';
COMMENT ON COLUMN keplersc.kdconflealtad.c2 IS 'Sucursal de ventas';
COMMENT ON COLUMN keplersc.kdconflealtad.c1 IS 'Llave';

