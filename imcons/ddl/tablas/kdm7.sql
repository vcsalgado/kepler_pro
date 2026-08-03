CREATE  TABLE keplersc.kdm7 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(60) NOT NULL DEFAULT ''::character varying,
  c9 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm7 ON keplersc.kdm7 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm7 IS 'Descripciones de documentos';
COMMENT ON COLUMN keplersc.kdm7.c9 IS 'Monto';
COMMENT ON COLUMN keplersc.kdm7.c8 IS 'Descripcion de renglon';
COMMENT ON COLUMN keplersc.kdm7.c7 IS 'Numero partida';
COMMENT ON COLUMN keplersc.kdm7.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm7.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm7.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm7.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm7.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm7.c1 IS 'Sucursal';

