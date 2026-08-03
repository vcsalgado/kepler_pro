CREATE  TABLE keplersc.kdpesopuntos (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpesopuntos ADD CONSTRAINT pk_kdpesopuntos PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdpesopuntos IS 'Peso de Puntos';
COMMENT ON COLUMN keplersc.kdpesopuntos.c3 IS 'Peso';
COMMENT ON COLUMN keplersc.kdpesopuntos.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdpesopuntos.c1 IS 'Tipo de punto';

