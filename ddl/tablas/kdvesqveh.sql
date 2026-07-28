CREATE  TABLE keplersc.kdvesqveh (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(5) NOT NULL DEFAULT ''::character varying,
  c3 character varying(5) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(5) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvesqveh ADD CONSTRAINT pk_kdvesqveh PRIMARY KEY (c1, c2, c3, c4);
COMMENT ON TABLE keplersc.kdvesqveh IS 'Ventas Esquema Vehiculos';
COMMENT ON COLUMN keplersc.kdvesqveh.c5 IS 'Tipo Comision';
COMMENT ON COLUMN keplersc.kdvesqveh.c4 IS 'Operacion';
COMMENT ON COLUMN keplersc.kdvesqveh.c3 IS 'Esquema';
COMMENT ON COLUMN keplersc.kdvesqveh.c2 IS 'Tipo Auto';
COMMENT ON COLUMN keplersc.kdvesqveh.c1 IS 'Sucursal';

