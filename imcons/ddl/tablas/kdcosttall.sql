CREATE  TABLE keplersc.kdcosttall (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric(10,5) NOT NULL DEFAULT 0,
  c9 numeric(10,2) NOT NULL DEFAULT 0,
  c10 numeric(10,2) NOT NULL DEFAULT 0,
  c11 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcosttall ADD CONSTRAINT pk_kdcosttall PRIMARY KEY (c1, c2, c3, c4, c5, c6);
COMMENT ON TABLE keplersc.kdcosttall IS 'Costo Taller';
COMMENT ON COLUMN keplersc.kdcosttall.c9 IS 'Costo Refacciones';
COMMENT ON COLUMN keplersc.kdcosttall.c8 IS 'Horas Mano de Obra';
COMMENT ON COLUMN keplersc.kdcosttall.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdcosttall.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcosttall.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcosttall.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcosttall.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdcosttall.c11 IS 'Costo Cargos Varios';
COMMENT ON COLUMN keplersc.kdcosttall.c10 IS 'Costo TOTs';
COMMENT ON COLUMN keplersc.kdcosttall.c1 IS 'Sucursal';

