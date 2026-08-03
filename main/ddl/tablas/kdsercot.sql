CREATE  TABLE keplersc.kdsercot (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 character varying(8) NULL DEFAULT ''::character varying,
  c5 character varying(1) NULL DEFAULT ''::character varying,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(8) NULL DEFAULT ''::character varying,
  c8 character varying(1) NULL DEFAULT ''::character varying,
  c9 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c10 character varying(8) NULL DEFAULT ''::character varying,
  c11 character varying(1) NULL DEFAULT ''::character varying,
  c12 character varying(1) NULL DEFAULT ''::character varying,
  c13 character varying(10) NULL DEFAULT ''::character varying,
  c14 character varying(1) NULL DEFAULT ''::character varying,
  c15 character varying(1) NULL DEFAULT ''::character varying,
  c16 character varying(1) NULL DEFAULT ''::character varying,
  c17 numeric NULL DEFAULT 0,
  c18 numeric NULL DEFAULT 0,
  c19 character varying(7) NULL DEFAULT ''::character varying,
  c20 character varying(1) NULL DEFAULT ''::character varying,
  c21 character varying(5) NULL DEFAULT ''::character varying,
  c22 character varying(5) NULL DEFAULT ''::character varying,
  c23 character varying(1) NULL DEFAULT ''::character varying,
  c24 character varying(5) NULL DEFAULT ''::character varying,
  c25 character varying(5) NULL DEFAULT ''::character varying,
  c26 character varying(1) NULL DEFAULT ''::character varying,
  c27 character varying(5) NULL DEFAULT ''::character varying,
  c28 character varying(5) NULL DEFAULT ''::character varying,
  c29 character varying(1) NULL DEFAULT ''::character varying,
  c30 character varying(7) NULL DEFAULT ''::character varying,
  c31 character varying(130) NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsercot ADD CONSTRAINT kdsercot_pk PRIMARY KEY (c1, c2);
CREATE UNIQUE INDEX IF NOT EXISTS kdsercot_c1_idx ON keplersc.kdsercot USING btree (c1, c2) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdsercot.c9 IS 'Fecha de la Autorizacion';
COMMENT ON COLUMN keplersc.kdsercot.c7 IS 'Hora de la Cotizacion';
COMMENT ON COLUMN keplersc.kdsercot.c6 IS 'Fecha de la Cotizacion';
COMMENT ON COLUMN keplersc.kdsercot.c4 IS 'Hora de la Solicitud';
COMMENT ON COLUMN keplersc.kdsercot.c31 IS 'Nombre del Cliente';
COMMENT ON COLUMN keplersc.kdsercot.c30 IS 'Cliente';
COMMENT ON COLUMN keplersc.kdsercot.c3 IS 'Fecha de la Solititud';
COMMENT ON COLUMN keplersc.kdsercot.c28 IS 'Asesor que Autoriza';
COMMENT ON COLUMN keplersc.kdsercot.c27 IS 'Operario que Autoriza';
COMMENT ON COLUMN keplersc.kdsercot.c25 IS 'Asesor que Cotiza';
COMMENT ON COLUMN keplersc.kdsercot.c24 IS 'Operario que Cotiza';
COMMENT ON COLUMN keplersc.kdsercot.c22 IS 'Asesor que solicita';
COMMENT ON COLUMN keplersc.kdsercot.c21 IS 'Operario que solicita';
COMMENT ON COLUMN keplersc.kdsercot.c2 IS 'Folio de la Cotizacion';
COMMENT ON COLUMN keplersc.kdsercot.c19 IS 'Folio';
COMMENT ON COLUMN keplersc.kdsercot.c18 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdsercot.c17 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdsercot.c16 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdsercot.c15 IS 'Genero';
COMMENT ON COLUMN keplersc.kdsercot.c13 IS 'Orden';
COMMENT ON COLUMN keplersc.kdsercot.c12 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdsercot.c10 IS 'Hora de la Autorizacion';
COMMENT ON COLUMN keplersc.kdsercot.c1 IS 'Sucursal';

