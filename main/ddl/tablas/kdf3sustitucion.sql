CREATE  TABLE keplersc.kdf3sustitucion (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying,
  c11 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3sustitucion ADD CONSTRAINT pk_kdf3sustitucion PRIMARY KEY (c1, c2, c3, c4, c5, c6);
CREATE INDEX IF NOT EXISTS sindkdf3sustitucion02 ON keplersc.kdf3sustitucion USING btree (c1, c2, c3, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdf3sustitucion.c9 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c8 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c7 IS 'Fecha Recubo otiginal';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c11 IS 'Fecha del que sustituye';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3sustitucion.c1 IS 'Sucursal';

