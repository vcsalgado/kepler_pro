CREATE  TABLE keplersc.kdserconfctas (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 numeric(6,3) NOT NULL DEFAULT 0,
  c11 numeric(6,3) NOT NULL DEFAULT 0,
  c12 numeric NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 numeric NOT NULL DEFAULT 0,
  c18 numeric NOT NULL DEFAULT 0,
  c19 numeric NOT NULL DEFAULT 0,
  c20 numeric NOT NULL DEFAULT 0,
  c21 numeric NOT NULL DEFAULT 0,
  c22 numeric NOT NULL DEFAULT 0,
  c23 numeric NOT NULL DEFAULT 0,
  c24 numeric NOT NULL DEFAULT 0,
  c25 numeric NOT NULL DEFAULT 0,
  c26 numeric(6,3) NOT NULL DEFAULT 0,
  c27 numeric(6,3) NOT NULL DEFAULT 0,
  c28 numeric(6,3) NOT NULL DEFAULT 0,
  c29 numeric(6,3) NOT NULL DEFAULT 0,
  c30 numeric(6,3) NOT NULL DEFAULT 0,
  c31 numeric NULL,
  c32 numeric NULL,
  c33 numeric NULL,
  c34 character varying(2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdserconfctas ADD CONSTRAINT pk_kdserconfctas PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdserconfctas IS 'Configuracion del Modulo de Citas';
COMMENT ON COLUMN keplersc.kdserconfctas.c9 IS 'Validar citas por operario';
COMMENT ON COLUMN keplersc.kdserconfctas.c8 IS 'Validar citas por recepcionista';
COMMENT ON COLUMN keplersc.kdserconfctas.c7 IS 'Maximo de horas por tecnico de servicios';
COMMENT ON COLUMN keplersc.kdserconfctas.c6 IS 'Porcentaje de horas vendibles por dia';
COMMENT ON COLUMN keplersc.kdserconfctas.c5 IS 'Maximo horas laborables sabado';
COMMENT ON COLUMN keplersc.kdserconfctas.c4 IS 'Maximo horas laborables entre semana';
COMMENT ON COLUMN keplersc.kdserconfctas.c34 IS 'horas a considerar por reclamaciones (R)';
COMMENT ON COLUMN keplersc.kdserconfctas.c33 IS 'hora limite laborable domingo';
COMMENT ON COLUMN keplersc.kdserconfctas.c32 IS 'hora limite laborable sabado';
COMMENT ON COLUMN keplersc.kdserconfctas.c31 IS 'hora limite laborable entre semana';
COMMENT ON COLUMN keplersc.kdserconfctas.c30 IS 'horas a considerar por punto previas (Q)';
COMMENT ON COLUMN keplersc.kdserconfctas.c3 IS 'Maximo de citas por recepcionistas por cuarto de hora';
COMMENT ON COLUMN keplersc.kdserconfctas.c29 IS 'horas a considerar por punto internas (I)';
COMMENT ON COLUMN keplersc.kdserconfctas.c28 IS 'horas a considerar por punto garantias (G)';
COMMENT ON COLUMN keplersc.kdserconfctas.c27 IS 'horas a considerar por punto hojalateria (H)';
COMMENT ON COLUMN keplersc.kdserconfctas.c26 IS 'horas a considerar por punto presupuestos (P)';
COMMENT ON COLUMN keplersc.kdserconfctas.c2 IS 'Numero de recepcionistas';
COMMENT ON COLUMN keplersc.kdserconfctas.c14 IS 'Aplicar validaciones recepcionista (G,I,Q,R)';
COMMENT ON COLUMN keplersc.kdserconfctas.c13 IS 'Minutos para considerar un no show';
COMMENT ON COLUMN keplersc.kdserconfctas.c12 IS 'Forzar chequeos en pantalla de citas y ordenes';
COMMENT ON COLUMN keplersc.kdserconfctas.c11 IS 'Horas a considerar por lavado (L)';
COMMENT ON COLUMN keplersc.kdserconfctas.c10 IS 'Horas a considerar por punto de falla (F)';
COMMENT ON COLUMN keplersc.kdserconfctas.c1 IS 'ID Consecutivo';

