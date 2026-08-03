CREATE  TABLE keplersc.kdedoresctas (
  c1 integer NOT NULL,
  c2 character varying(50) NULL,
  c3 character varying(20) NULL,
  c4 character varying(20) NULL,
  c5 numeric NULL,
  c6 boolean NULL,
  c7 character varying(50) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdedoresctas ADD CONSTRAINT kdedoresctas_pk PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdedoresctas.c7 IS 'Titulo Totales';
COMMENT ON COLUMN keplersc.kdedoresctas.c6 IS 'lleva total';
COMMENT ON COLUMN keplersc.kdedoresctas.c5 IS 'multiplicador';
COMMENT ON COLUMN keplersc.kdedoresctas.c4 IS 'Cuenta final';
COMMENT ON COLUMN keplersc.kdedoresctas.c3 IS 'Cuenta inicial';
COMMENT ON COLUMN keplersc.kdedoresctas.c2 IS 'Nombre cuenta de resultados';
COMMENT ON COLUMN keplersc.kdedoresctas.c1 IS 'ID';

