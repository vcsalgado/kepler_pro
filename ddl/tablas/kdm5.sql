CREATE  TABLE keplersc.kdm5 (
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
  c13 numeric(15,6) NOT NULL DEFAULT 0,
  c14 character varying(40) NOT NULL DEFAULT ''::character varying,
  c15 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c16 numeric NULL,
  c17 numeric(15,2) NULL,
  col_foliomig character varying(10) NULL,
  col_foliofin character varying(10) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdm5 ON keplersc.kdm5 USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdm5 IS 'Documentos a Saldar por documento';
COMMENT ON COLUMN keplersc.kdm5.c9 IS 'Numero grupo';
COMMENT ON COLUMN keplersc.kdm5.c8 IS 'Naturaleza docto';
COMMENT ON COLUMN keplersc.kdm5.c7 IS 'Numero partida';
COMMENT ON COLUMN keplersc.kdm5.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdm5.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdm5.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdm5.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdm5.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdm5.c17 IS 'Otros Cargos';
COMMENT ON COLUMN keplersc.kdm5.c16 IS 'Numero de Docto';
COMMENT ON COLUMN keplersc.kdm5.c15 IS 'Vencimiento';
COMMENT ON COLUMN keplersc.kdm5.c14 IS 'Referencia documento';
COMMENT ON COLUMN keplersc.kdm5.c13 IS 'Monto abono o IVA';
COMMENT ON COLUMN keplersc.kdm5.c12 IS 'Monto cargo o monto';
COMMENT ON COLUMN keplersc.kdm5.c11 IS 'Folio documento';
COMMENT ON COLUMN keplersc.kdm5.c10 IS 'Numero tipo';
COMMENT ON COLUMN keplersc.kdm5.c1 IS 'Sucursal';

