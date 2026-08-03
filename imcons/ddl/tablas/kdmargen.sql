CREATE  TABLE keplersc.kdmargen (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying,
  c4 numeric(15,2) NOT NULL DEFAULT 0,
  c5 numeric(15,10) NOT NULL DEFAULT 0,
  c6 numeric(15,10) NOT NULL DEFAULT 0,
  c7 numeric(15,10) NOT NULL DEFAULT 0,
  c8 numeric(6,3) NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric(15,10) NOT NULL DEFAULT 0,
  c11 numeric(5,2) NOT NULL DEFAULT 0,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 numeric(6,3) NOT NULL DEFAULT 0,
  c16 numeric(9,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmargen ADD CONSTRAINT pk_kdmargen PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdmargen IS 'Margen de utilidad';
COMMENT ON COLUMN keplersc.kdmargen.c9 IS 'Folio actual';
COMMENT ON COLUMN keplersc.kdmargen.c8 IS 'Factor de conversion';
COMMENT ON COLUMN keplersc.kdmargen.c7 IS 'MArgen sobre cargos varios';
COMMENT ON COLUMN keplersc.kdmargen.c6 IS 'Margen sobre TOTs';
COMMENT ON COLUMN keplersc.kdmargen.c5 IS 'Margen sobre refacciones y materiales internos';
COMMENT ON COLUMN keplersc.kdmargen.c4 IS 'Precio por Hora de Mano de obra';
COMMENT ON COLUMN keplersc.kdmargen.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdmargen.c2 IS 'Tipo de Trabajo, tipo cita';
COMMENT ON COLUMN keplersc.kdmargen.c16 IS 'Cargos varios default por diagnostico';
COMMENT ON COLUMN keplersc.kdmargen.c15 IS 'Horas default por diagnostico';
COMMENT ON COLUMN keplersc.kdmargen.c14 IS 'Grupo de Folio';
COMMENT ON COLUMN keplersc.kdmargen.c13 IS 'Preferencia';
COMMENT ON COLUMN keplersc.kdmargen.c12 IS 'Imprimir vale de salida';
COMMENT ON COLUMN keplersc.kdmargen.c11 IS 'IVA';
COMMENT ON COLUMN keplersc.kdmargen.c10 IS 'Margen sobre refacciones y materiales externos';
COMMENT ON COLUMN keplersc.kdmargen.c1 IS 'Tipo orden';

