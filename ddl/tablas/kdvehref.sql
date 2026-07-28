CREATE  TABLE keplersc.kdvehref (
  c1 character varying(12) NOT NULL DEFAULT ''::character varying,
  c2 character varying(18) NOT NULL DEFAULT ''::character varying,
  c3 character varying(7) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvehref ADD CONSTRAINT pk_kdvehref PRIMARY KEY (c4, c1);
CREATE INDEX IF NOT EXISTS sindkdvehref02 ON keplersc.kdvehref USING btree (c1, c2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvehref03 ON keplersc.kdvehref USING btree (c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdvehref04 ON keplersc.kdvehref USING btree (c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdvehref.c5 IS 'Fecha de Importación';
COMMENT ON COLUMN keplersc.kdvehref.c4 IS 'Estatus';
COMMENT ON COLUMN keplersc.kdvehref.c3 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdvehref.c2 IS 'Serie';
COMMENT ON COLUMN keplersc.kdvehref.c1 IS 'Referencia';

