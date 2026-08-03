CREATE  TABLE keplersc.kdinvrdif (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 character varying(18) NOT NULL DEFAULT ''::character varying,
  c9 double precision NOT NULL DEFAULT 0,
  c10 double precision NOT NULL DEFAULT 0,
  c11 double precision NOT NULL DEFAULT 0,
  c12 double precision NOT NULL DEFAULT 0,
  c13 double precision NOT NULL DEFAULT 0,
  c14 double precision NOT NULL DEFAULT 0
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdinvrdif ON keplersc.kdinvrdif USING btree (c1, c2, c3, c4, c5, c6, c7) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdinvrdif IS 'Ajustes de inventario por Documentos';
COMMENT ON COLUMN keplersc.kdinvrdif.c9 IS 'Inv Teorico';
COMMENT ON COLUMN keplersc.kdinvrdif.c8 IS 'Clave producto';
COMMENT ON COLUMN keplersc.kdinvrdif.c7 IS 'Numero partida';
COMMENT ON COLUMN keplersc.kdinvrdif.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdinvrdif.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdinvrdif.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdinvrdif.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdinvrdif.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdinvrdif.c14 IS 'Costo Diferencia';
COMMENT ON COLUMN keplersc.kdinvrdif.c13 IS 'Inv Diferencia';
COMMENT ON COLUMN keplersc.kdinvrdif.c12 IS 'Costo Fisico';
COMMENT ON COLUMN keplersc.kdinvrdif.c11 IS 'Inv Fisico';
COMMENT ON COLUMN keplersc.kdinvrdif.c10 IS 'Costo Teorico';
COMMENT ON COLUMN keplersc.kdinvrdif.c1 IS 'Clave sucursal';

