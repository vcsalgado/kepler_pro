CREATE  TABLE keplersc.kdf3cliente (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(7) NOT NULL DEFAULT ''::character varying,
  c9 character varying(130) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(70) NOT NULL DEFAULT ''::character varying,
  c12 character varying(70) NOT NULL DEFAULT ''::character varying,
  c13 character varying(18) NOT NULL DEFAULT ''::character varying,
  c14 character varying(80) NOT NULL DEFAULT ''::character varying,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 character varying(27) NOT NULL DEFAULT ''::character varying,
  c17 character varying(27) NOT NULL DEFAULT ''::character varying,
  c18 character varying(70) NOT NULL DEFAULT ''::character varying,
  c19 character varying(35) NOT NULL DEFAULT ''::character varying,
  c20 character varying(35) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3cliente ADD CONSTRAINT pk_kdf3cliente PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
COMMENT ON TABLE keplersc.kdf3cliente IS 'f3 Cliente';
COMMENT ON COLUMN keplersc.kdf3cliente.c9 IS 'Nombre Cliente';
COMMENT ON COLUMN keplersc.kdf3cliente.c8 IS 'Clave Cliente';
COMMENT ON COLUMN keplersc.kdf3cliente.c7 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdf3cliente.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3cliente.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3cliente.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3cliente.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3cliente.c20 IS 'Pais';
COMMENT ON COLUMN keplersc.kdf3cliente.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3cliente.c19 IS 'Estado';
COMMENT ON COLUMN keplersc.kdf3cliente.c18 IS 'Municipio';
COMMENT ON COLUMN keplersc.kdf3cliente.c17 IS 'Numm int';
COMMENT ON COLUMN keplersc.kdf3cliente.c16 IS 'Num Ext';
COMMENT ON COLUMN keplersc.kdf3cliente.c15 IS 'CP';
COMMENT ON COLUMN keplersc.kdf3cliente.c14 IS 'Direccion internet';
COMMENT ON COLUMN keplersc.kdf3cliente.c13 IS 'RFC';
COMMENT ON COLUMN keplersc.kdf3cliente.c12 IS 'Poblacion';
COMMENT ON COLUMN keplersc.kdf3cliente.c11 IS 'Colonia';
COMMENT ON COLUMN keplersc.kdf3cliente.c10 IS 'Calley numero';
COMMENT ON COLUMN keplersc.kdf3cliente.c1 IS 'Sucursal';

