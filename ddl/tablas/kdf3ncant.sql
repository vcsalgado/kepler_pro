CREATE  TABLE keplersc.kdf3ncant (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 numeric NOT NULL DEFAULT 0,
  c11 numeric NOT NULL DEFAULT 0,
  c12 character varying(10) NOT NULL DEFAULT ''::character varying,
  c13 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  tipo_relacion character varying(2) NOT NULL DEFAULT ''::character varying,
  genero_doctorel character varying(1) NOT NULL DEFAULT ''::character varying,
  naturaleza_doctorel character varying(1) NOT NULL DEFAULT ''::character varying,
  grupo_doctorel numeric NOT NULL DEFAULT 0,
  tipo_doctorel numeric NOT NULL DEFAULT 0,
  folio_relacionado character varying(17) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3ncant ADD CONSTRAINT pk_kdf3ncant PRIMARY KEY (c1, c2, c3, c4, c5, c6);
CREATE INDEX IF NOT EXISTS sindkdf3ncant02 ON keplersc.kdf3ncant USING btree (c1, c8, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdf3ncant03 ON keplersc.kdf3ncant USING btree (c1, c8, c7, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdf3ncant04 ON keplersc.kdf3ncant USING btree (c1, c7, c2, c3, c4, c5, c6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdf3ncant_c1_idx ON keplersc.kdf3ncant USING btree (c1, c2, c3, c4, folio_relacionado) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdf3ncant_c2_idx ON keplersc.kdf3ncant USING btree (c1, genero_doctorel, naturaleza_doctorel, grupo_doctorel, tipo_doctorel, folio_relacionado) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS kdf3ncant_c3_idx ON keplersc.kdf3ncant USING btree (c1, c2, c9, c10, c11, c12) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdf3ncant IS 'f3 Notas de credito';
COMMENT ON COLUMN keplersc.kdf3ncant.tipo_relacion IS 'Tipo de relacion CFDI';
COMMENT ON COLUMN keplersc.kdf3ncant.tipo_doctorel IS 'Tipo documento relacionado';
COMMENT ON COLUMN keplersc.kdf3ncant.naturaleza_doctorel IS 'Naturaleza documento relacionado';
COMMENT ON COLUMN keplersc.kdf3ncant.grupo_doctorel IS 'Grupo documento relacionado';
COMMENT ON COLUMN keplersc.kdf3ncant.genero_doctorel IS 'Genero documento relacionado';
COMMENT ON COLUMN keplersc.kdf3ncant.folio_relacionado IS 'Folio relacionado';
COMMENT ON COLUMN keplersc.kdf3ncant.c9 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3ncant.c8 IS '0 Sin NC 1 Con NC';
COMMENT ON COLUMN keplersc.kdf3ncant.c7 IS 'Fecha anticipio';
COMMENT ON COLUMN keplersc.kdf3ncant.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3ncant.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3ncant.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3ncant.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3ncant.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3ncant.c13 IS 'Fecha Nota Credito';
COMMENT ON COLUMN keplersc.kdf3ncant.c12 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3ncant.c11 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3ncant.c10 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3ncant.c1 IS 'Sucursal';

