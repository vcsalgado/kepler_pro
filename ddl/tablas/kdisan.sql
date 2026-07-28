CREATE  TABLE keplersc.kdisan (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(60) NOT NULL DEFAULT ''::character varying,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdisan ADD CONSTRAINT pk_kdisan PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdisan IS 'ISAN';
COMMENT ON COLUMN keplersc.kdisan.c9 IS 'Cuota de Excedente';
COMMENT ON COLUMN keplersc.kdisan.c8 IS 'Porcentaje de Reducción';
COMMENT ON COLUMN keplersc.kdisan.c7 IS 'Tarifa';
COMMENT ON COLUMN keplersc.kdisan.c6 IS 'Porcentaje';
COMMENT ON COLUMN keplersc.kdisan.c5 IS 'Límite Superior';
COMMENT ON COLUMN keplersc.kdisan.c4 IS 'Límite Inferior';
COMMENT ON COLUMN keplersc.kdisan.c3 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdisan.c2 IS 'Código';
COMMENT ON COLUMN keplersc.kdisan.c10 IS 'Restador';
COMMENT ON COLUMN keplersc.kdisan.c1 IS 'Tipo de Cálculo';

