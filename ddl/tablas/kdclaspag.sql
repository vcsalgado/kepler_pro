CREATE  TABLE keplersc.kdclaspag (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 numeric(10,5) NOT NULL DEFAULT 0,
  c4 numeric(10,5) NOT NULL DEFAULT 0,
  c5 numeric(15,2) NOT NULL DEFAULT 0,
  c6 numeric(10,5) NOT NULL DEFAULT 0,
  c7 numeric(10,5) NOT NULL DEFAULT 0,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 numeric(10,5) NOT NULL DEFAULT 0,
  c10 numeric(10,5) NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 numeric(10,5) NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric(10,5) NOT NULL DEFAULT 0,
  c15 numeric NOT NULL DEFAULT 0,
  c16 numeric(10,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdclaspag ADD CONSTRAINT pk_kdclaspag PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdclaspag IS 'Tipos de pagos a operarios';
COMMENT ON COLUMN keplersc.kdclaspag.c9 IS '% Previas';
COMMENT ON COLUMN keplersc.kdclaspag.c8 IS '% Internas';
COMMENT ON COLUMN keplersc.kdclaspag.c7 IS '% Garantias';
COMMENT ON COLUMN keplersc.kdclaspag.c6 IS '% Normales';
COMMENT ON COLUMN keplersc.kdclaspag.c5 IS 'Sueldo Base';
COMMENT ON COLUMN keplersc.kdclaspag.c4 IS 'Tarifa por Hora';
COMMENT ON COLUMN keplersc.kdclaspag.c3 IS 'Horas Base';
COMMENT ON COLUMN keplersc.kdclaspag.c2 IS 'Descripcion del Pago';
COMMENT ON COLUMN keplersc.kdclaspag.c16 IS 'Tarifa Ultimo Escalon';
COMMENT ON COLUMN keplersc.kdclaspag.c15 IS 'Escalon 3';
COMMENT ON COLUMN keplersc.kdclaspag.c14 IS 'Tarifa Escalon 3';
COMMENT ON COLUMN keplersc.kdclaspag.c13 IS 'Escalon 2';
COMMENT ON COLUMN keplersc.kdclaspag.c12 IS 'Tarifa Escalon 2';
COMMENT ON COLUMN keplersc.kdclaspag.c11 IS 'Escalon 1';
COMMENT ON COLUMN keplersc.kdclaspag.c10 IS '% Reclamaciones';
COMMENT ON COLUMN keplersc.kdclaspag.c1 IS 'Clave del Pago';

