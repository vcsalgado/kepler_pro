CREATE  TABLE keplersc.kdm9 (
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
  c11 character varying(7) NOT NULL DEFAULT ''::character varying,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 character varying(5) NOT NULL DEFAULT ''::character varying,
  c14 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm9 ON keplersc.kdm9 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm9 IS 'Documentos secundarios por partida';
COMMENT ON COLUMN keplersc.kdm9.c9 IS 'Grupo documento secundario';
COMMENT ON COLUMN keplersc.kdm9.c8 IS 'Naturaleza documento secundario';
COMMENT ON COLUMN keplersc.kdm9.c7 IS 'Número partida';
COMMENT ON COLUMN keplersc.kdm9.c6 IS 'Folio documento base';
COMMENT ON COLUMN keplersc.kdm9.c5 IS 'Tipo documeto base';
COMMENT ON COLUMN keplersc.kdm9.c4 IS 'Grupo documento base';
COMMENT ON COLUMN keplersc.kdm9.c3 IS 'Naturaleza documento base';
COMMENT ON COLUMN keplersc.kdm9.c2 IS 'Genero documento base';
COMMENT ON COLUMN keplersc.kdm9.c14 IS 'Paridad documento secundario';
COMMENT ON COLUMN keplersc.kdm9.c13 IS 'Moneda';
COMMENT ON COLUMN keplersc.kdm9.c12 IS 'Monto';
COMMENT ON COLUMN keplersc.kdm9.c11 IS 'Folio documento secundario';
COMMENT ON COLUMN keplersc.kdm9.c10 IS 'Tipo documento secundario';
COMMENT ON COLUMN keplersc.kdm9.c1 IS 'Sucursal';

