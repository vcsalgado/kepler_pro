CREATE  TABLE keplersc.kdlealtadmovs (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(20,6) NOT NULL DEFAULT 0,
  c10 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdlealtadmovs ADD CONSTRAINT kdlealtadmovs_pk PRIMARY KEY (c1, c2, c3, c4, c7, c8);
COMMENT ON COLUMN keplersc.kdlealtadmovs.c9 IS 'Var 1';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c7 IS 'H(Horas),R(Refs),T(Tots),C(Cargos Varios)';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c6 IS 'Clave Paquete';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c5 IS 'Tipo Punto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c4 IS 'Punto';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c10 IS 'Var 2';
COMMENT ON COLUMN keplersc.kdlealtadmovs.c1 IS 'Sucursal';

