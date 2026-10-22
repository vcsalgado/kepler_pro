CREATE  TABLE keplersc.kdf3anticipos (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(2) NOT NULL DEFAULT ''::character varying,
  c10 character varying(7) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 numeric NOT NULL DEFAULT 0,
  c15 character varying(10) NOT NULL DEFAULT ''::character varying,
  c16 numeric(15,2) NOT NULL DEFAULT 0,
  c17 numeric(15,2) NOT NULL DEFAULT 0,
  c18 numeric(15,2) NOT NULL DEFAULT 0,
  c19 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3anticipos ADD CONSTRAINT pk_kdf3anticipos PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
CREATE INDEX IF NOT EXISTS sindkdf3anticipos ON keplersc.kdf3anticipos USING btree (c10, c11, c12, c13, c14, c15, c19) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdf3anticipos.c9 IS 'Tipo relación';
COMMENT ON COLUMN keplersc.kdf3anticipos.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdf3anticipos.c7 IS 'Consecutivo CFDI';
COMMENT ON COLUMN keplersc.kdf3anticipos.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3anticipos.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3anticipos.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3anticipos.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3anticipos.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3anticipos.c17 IS 'Importe anticipo seleccionado';
COMMENT ON COLUMN keplersc.kdf3anticipos.c15 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3anticipos.c14 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3anticipos.c13 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3anticipos.c12 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3anticipos.c11 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3anticipos.c10 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdf3anticipos.c1 IS 'Sucursal';

