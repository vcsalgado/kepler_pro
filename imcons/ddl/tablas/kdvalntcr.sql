CREATE  TABLE keplersc.kdvalntcr (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvalntcr ADD CONSTRAINT pk_kdvalntcr PRIMARY KEY (c1, c2, c3, c4, c5, c6);
CREATE INDEX IF NOT EXISTS sindkdvalntcr02 ON keplersc.kdvalntcr USING btree (c1, c2, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvalntcr.c9 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvalntcr.c8 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvalntcr.c7 IS 'Naturaleza que ampara';
COMMENT ON COLUMN keplersc.kdvalntcr.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvalntcr.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdvalntcr.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdvalntcr.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdvalntcr.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdvalntcr.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdvalntcr.c1 IS 'Sucursal';

