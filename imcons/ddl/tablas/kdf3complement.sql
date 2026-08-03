CREATE  TABLE keplersc.kdf3complement (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(15,2) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(10) NOT NULL DEFAULT ''::character varying,
  c12 character varying(20) NOT NULL DEFAULT ''::character varying,
  c13 character varying(50) NOT NULL DEFAULT ''::character varying,
  c14 character varying(4) NOT NULL DEFAULT ''::character varying,
  c15 character varying(20) NOT NULL DEFAULT ''::character varying,
  c16 character varying(17) NOT NULL DEFAULT ''::character varying,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 character varying(20) NOT NULL DEFAULT ''::character varying,
  c19 character varying(10) NOT NULL DEFAULT ''::character varying,
  c20 character varying(20) NOT NULL DEFAULT ''::character varying,
  c21 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3complement ADD CONSTRAINT pk_kdf3complement PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
COMMENT ON TABLE keplersc.kdf3complement IS 'f3 complemento';
COMMENT ON COLUMN keplersc.kdf3complement.c9 IS 'Importe original vehículo';
COMMENT ON COLUMN keplersc.kdf3complement.c8 IS 'Consecutivo complemento';
COMMENT ON COLUMN keplersc.kdf3complement.c7 IS 'Consecutivo Cfdi';
COMMENT ON COLUMN keplersc.kdf3complement.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3complement.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3complement.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3complement.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3complement.c21 IS 'Aduana';
COMMENT ON COLUMN keplersc.kdf3complement.c20 IS 'NIV';
COMMENT ON COLUMN keplersc.kdf3complement.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3complement.c19 IS 'Fecha importación';
COMMENT ON COLUMN keplersc.kdf3complement.c18 IS 'Número importación';
COMMENT ON COLUMN keplersc.kdf3complement.c17 IS 'Valor libro';
COMMENT ON COLUMN keplersc.kdf3complement.c16 IS 'VIN';
COMMENT ON COLUMN keplersc.kdf3complement.c15 IS 'Número motor';
COMMENT ON COLUMN keplersc.kdf3complement.c14 IS 'Año modelo';
COMMENT ON COLUMN keplersc.kdf3complement.c13 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdf3complement.c12 IS 'Marca';
COMMENT ON COLUMN keplersc.kdf3complement.c11 IS 'Clave vehícular';
COMMENT ON COLUMN keplersc.kdf3complement.c10 IS 'Importe toma vehículo';
COMMENT ON COLUMN keplersc.kdf3complement.c1 IS 'Sucursal';

