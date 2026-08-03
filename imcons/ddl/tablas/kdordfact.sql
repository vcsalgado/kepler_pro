CREATE  TABLE keplersc.kdordfact (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(10) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordfact ADD CONSTRAINT pk_kdordfact PRIMARY KEY (c1, c2, c3, c4);
CREATE INDEX IF NOT EXISTS sindkdordfact02 ON keplersc.kdordfact USING btree (c1, c6, c7, c8, c9, c10) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdordfact.c9 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdordfact.c8 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdordfact.c7 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdordfact.c6 IS 'Genero';
COMMENT ON COLUMN keplersc.kdordfact.c5 IS 'Alta 0; Baja 10';
COMMENT ON COLUMN keplersc.kdordfact.c4 IS 'Consecutivo';
COMMENT ON COLUMN keplersc.kdordfact.c3 IS 'Folio Orden';
COMMENT ON COLUMN keplersc.kdordfact.c2 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdordfact.c10 IS 'Folio';
COMMENT ON COLUMN keplersc.kdordfact.c1 IS 'Sucursal';

