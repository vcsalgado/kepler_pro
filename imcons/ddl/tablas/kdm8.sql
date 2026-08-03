CREATE  TABLE keplersc.kdm8 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric NOT NULL DEFAULT 0,
  c11 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm8 ON keplersc.kdm8 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm8 IS 'Documentos Anexados por documento';
COMMENT ON COLUMN keplersc.kdm8.c9 IS 'Grupo docto secundario';
COMMENT ON COLUMN keplersc.kdm8.c8 IS 'Naturaleza docto secunadario';
COMMENT ON COLUMN keplersc.kdm8.c7 IS 'No Partida';
COMMENT ON COLUMN keplersc.kdm8.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm8.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm8.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm8.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm8.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm8.c11 IS 'Folio documento secundario';
COMMENT ON COLUMN keplersc.kdm8.c10 IS 'Tipo docto secundario';
COMMENT ON COLUMN keplersc.kdm8.c1 IS 'Sucursal';

