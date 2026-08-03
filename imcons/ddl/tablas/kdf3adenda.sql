CREATE  TABLE keplersc.kdf3adenda (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(10) NOT NULL DEFAULT ''::character varying,
  c9 character varying(50) NOT NULL DEFAULT ''::character varying,
  c10 character varying(50) NOT NULL DEFAULT ''::character varying,
  c11 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3adenda ADD CONSTRAINT pk_kdf3adenda PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8, c9, c10);
COMMENT ON COLUMN keplersc.kdf3adenda.c9 IS 'Clave segmento';
COMMENT ON COLUMN keplersc.kdf3adenda.c8 IS 'Clave adenda';
COMMENT ON COLUMN keplersc.kdf3adenda.c7 IS 'Consecutivo CFDI';
COMMENT ON COLUMN keplersc.kdf3adenda.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3adenda.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3adenda.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3adenda.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3adenda.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3adenda.c11 IS 'Valor default';
COMMENT ON COLUMN keplersc.kdf3adenda.c10 IS 'Clave variable';
COMMENT ON COLUMN keplersc.kdf3adenda.c1 IS 'Sucursal';

