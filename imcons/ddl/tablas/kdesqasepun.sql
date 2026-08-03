CREATE  TABLE keplersc.kdesqasepun (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,2) NOT NULL DEFAULT 0,
  c3 numeric(10,5) NOT NULL DEFAULT 0,
  c4 numeric(10,2) NOT NULL DEFAULT 0,
  c5 numeric(10,5) NOT NULL DEFAULT 0,
  c6 numeric(10,2) NOT NULL DEFAULT 0,
  c7 numeric(10,5) NOT NULL DEFAULT 0,
  c8 numeric(10,2) NOT NULL DEFAULT 0,
  c9 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdesqasepun ADD CONSTRAINT pk_kdesqasepun PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdesqasepun IS 'Asesor esquema puntos';
COMMENT ON COLUMN keplersc.kdesqasepun.c9 IS 'Porcentaje 4 a pagar';
COMMENT ON COLUMN keplersc.kdesqasepun.c8 IS 'Escalon 4 utilidad';
COMMENT ON COLUMN keplersc.kdesqasepun.c7 IS 'Porcentaje 3 a pagar';
COMMENT ON COLUMN keplersc.kdesqasepun.c6 IS 'Escalon 3 utilidad';
COMMENT ON COLUMN keplersc.kdesqasepun.c5 IS 'Porcentaje 2 a pagar';
COMMENT ON COLUMN keplersc.kdesqasepun.c4 IS 'Escalon 2 utilidad';
COMMENT ON COLUMN keplersc.kdesqasepun.c3 IS 'Porcentaje 1 a pagar';
COMMENT ON COLUMN keplersc.kdesqasepun.c2 IS 'Escalon 1 utilidad';
COMMENT ON COLUMN keplersc.kdesqasepun.c1 IS 'Tipo de punto';

