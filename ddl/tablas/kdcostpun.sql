CREATE  TABLE keplersc.kdcostpun (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcostpun ADD CONSTRAINT pk_kdcostpun PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7);
COMMENT ON TABLE keplersc.kdcostpun IS 'Ordenes, costo por punto';
COMMENT ON COLUMN keplersc.kdcostpun.c9 IS 'Costo refacciones';
COMMENT ON COLUMN keplersc.kdcostpun.c8 IS 'Horas mano de obra';
COMMENT ON COLUMN keplersc.kdcostpun.c7 IS 'Punto';
COMMENT ON COLUMN keplersc.kdcostpun.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdcostpun.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcostpun.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcostpun.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcostpun.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdcostpun.c11 IS 'Costo Cargos Varios';
COMMENT ON COLUMN keplersc.kdcostpun.c10 IS 'Costo TOTs';
COMMENT ON COLUMN keplersc.kdcostpun.c1 IS 'Sucursal';

