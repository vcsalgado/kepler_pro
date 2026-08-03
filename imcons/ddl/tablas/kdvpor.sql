CREATE  TABLE keplersc.kdvpor (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(15,2) NOT NULL DEFAULT 0,
  c3 numeric(15,2) NOT NULL DEFAULT 0,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvpor ADD CONSTRAINT pk_kdvpor PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdvpor.c5 IS 'Porcentaje Utilidad otros';
COMMENT ON COLUMN keplersc.kdvpor.c4 IS 'Porcentaje Utilidad Accesorios';
COMMENT ON COLUMN keplersc.kdvpor.c3 IS 'Porcentaje de comision G Extendida';
COMMENT ON COLUMN keplersc.kdvpor.c2 IS 'Porcentaje de comision de seguro';
COMMENT ON COLUMN keplersc.kdvpor.c1 IS 'Tipo de Operacion';

