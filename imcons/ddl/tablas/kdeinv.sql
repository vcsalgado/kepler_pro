CREATE  TABLE keplersc.kdeinv (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(10) NOT NULL DEFAULT ''::character varying,
  c10 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c11 numeric(15,2) NOT NULL DEFAULT 0,
  c12 numeric(15,2) NOT NULL DEFAULT 0,
  c13 character varying(18) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdeinv ADD CONSTRAINT pk_kdeinv PRIMARY KEY (c1, c2, c3);
CREATE INDEX IF NOT EXISTS sindkdeinv02 ON keplersc.kdeinv USING btree (c1, c5, c6, c7, c8, c9) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdeinv03 ON keplersc.kdeinv USING btree (c1, c2, c10, c3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdeinv04 ON keplersc.kdeinv USING btree (c1, c13, c10, c3) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdeinv IS 'Autos Entrada Inventario';
COMMENT ON COLUMN keplersc.kdeinv.c9 IS 'Folio';
COMMENT ON COLUMN keplersc.kdeinv.c8 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdeinv.c7 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdeinv.c6 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdeinv.c5 IS 'Genero';
COMMENT ON COLUMN keplersc.kdeinv.c4 IS 'Tipo 0=Entrada 10=Salida';
COMMENT ON COLUMN keplersc.kdeinv.c3 IS 'Partida';
COMMENT ON COLUMN keplersc.kdeinv.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdeinv.c13 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdeinv.c12 IS 'IVA';
COMMENT ON COLUMN keplersc.kdeinv.c11 IS 'Costo';
COMMENT ON COLUMN keplersc.kdeinv.c10 IS 'Fecha ingreso';
COMMENT ON COLUMN keplersc.kdeinv.c1 IS 'Sucursal';

