CREATE  TABLE keplersc.kdm4 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(60) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm4 ON keplersc.kdm4 USING btree (c1, c2, c3, c4, c5, c6, c7, c8) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm4 IS 'Comentarios por partida';
COMMENT ON COLUMN keplersc.kdm4.c9 IS 'Comentario';
COMMENT ON COLUMN keplersc.kdm4.c8 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdm4.c7 IS 'Numero Partida';
COMMENT ON COLUMN keplersc.kdm4.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm4.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm4.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm4.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm4.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm4.c1 IS 'Sucursal';

