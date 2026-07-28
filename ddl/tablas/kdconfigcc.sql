CREATE  TABLE keplersc.kdconfigcc (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric(5,2) NOT NULL DEFAULT 0,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfigcc ADD CONSTRAINT pk_kdconfigcc PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdconfigcc IS 'Comisiones Contact Center';
COMMENT ON COLUMN keplersc.kdconfigcc.c3 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdconfigcc.c2 IS 'Porcentaje asesor contact center operacion';
COMMENT ON COLUMN keplersc.kdconfigcc.c1 IS 'Consecutivo';

