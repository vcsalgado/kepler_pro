CREATE  TABLE keplersc.kdf3longconcept (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 character varying(80) NOT NULL DEFAULT ''::character varying,
  c10 character varying(80) NOT NULL DEFAULT ''::character varying,
  c11 character varying(80) NOT NULL DEFAULT ''::character varying,
  c12 character varying(80) NOT NULL DEFAULT ''::character varying,
  c13 character varying(80) NOT NULL DEFAULT ''::character varying,
  c14 character varying(80) NOT NULL DEFAULT ''::character varying,
  c15 character varying(80) NOT NULL DEFAULT ''::character varying,
  c16 character varying(80) NOT NULL DEFAULT ''::character varying,
  c17 character varying(80) NOT NULL DEFAULT ''::character varying,
  c18 character varying(80) NOT NULL DEFAULT ''::character varying,
  c19 character varying(80) NOT NULL DEFAULT ''::character varying,
  c20 character varying(80) NOT NULL DEFAULT ''::character varying,
  c21 character varying(80) NOT NULL DEFAULT ''::character varying,
  c22 character varying(80) NOT NULL DEFAULT ''::character varying,
  c23 character varying(80) NOT NULL DEFAULT ''::character varying,
  c24 character varying(80) NOT NULL DEFAULT ''::character varying,
  c25 character varying(80) NOT NULL DEFAULT ''::character varying,
  c26 character varying(80) NOT NULL DEFAULT ''::character varying,
  c27 character varying(80) NOT NULL DEFAULT ''::character varying,
  c28 character varying(80) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3longconcept ADD CONSTRAINT pk_kdf3longconcept PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
COMMENT ON COLUMN keplersc.kdf3longconcept.c9 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdf3longconcept.c7 IS 'Consecutivo CFDI';
COMMENT ON COLUMN keplersc.kdf3longconcept.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3longconcept.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3longconcept.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3longconcept.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3longconcept.c28 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c27 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c26 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c25 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c24 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c23 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c22 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c21 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c20 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3longconcept.c19 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c18 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c17 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c16 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c15 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c14 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c13 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c12 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c11 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c10 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3longconcept.c1 IS 'Sucursal';

