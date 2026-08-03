CREATE  TABLE keplersc.kdf3concept (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(10) NOT NULL DEFAULT ''::character varying,
  c7 numeric NOT NULL DEFAULT 0,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric(15,6) NOT NULL DEFAULT 0,
  c10 character varying(3) NOT NULL DEFAULT ''::character varying,
  c11 character varying(18) NOT NULL DEFAULT ''::character varying,
  c12 character varying(300) NOT NULL DEFAULT ''::character varying,
  c13 numeric(20,6) NOT NULL DEFAULT 0,
  c14 numeric(20,6) NOT NULL DEFAULT 0,
  c15 character varying(3) NOT NULL DEFAULT ''::character varying,
  c16 character varying(10) NOT NULL DEFAULT ''::character varying,
  c17 numeric(7,4) NOT NULL DEFAULT 0,
  c18 numeric(20,6) NOT NULL DEFAULT 0,
  c19 character varying(30) NOT NULL DEFAULT ''::character varying,
  c20 numeric(20,6) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3concept ADD CONSTRAINT pk_kdf3concept PRIMARY KEY (c1, c2, c3, c4, c5, c6, c7, c8);
COMMENT ON TABLE keplersc.kdf3concept IS 'f3 Concepto';
COMMENT ON COLUMN keplersc.kdf3concept.c9 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdf3concept.c8 IS 'Partida';
COMMENT ON COLUMN keplersc.kdf3concept.c7 IS 'Concecutivo CFDI';
COMMENT ON COLUMN keplersc.kdf3concept.c6 IS 'Folio';
COMMENT ON COLUMN keplersc.kdf3concept.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdf3concept.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdf3concept.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdf3concept.c20 IS 'Monto base para impuesto';
COMMENT ON COLUMN keplersc.kdf3concept.c2 IS 'Genero';
COMMENT ON COLUMN keplersc.kdf3concept.c19 IS 'Clave producto o servicio';
COMMENT ON COLUMN keplersc.kdf3concept.c18 IS 'Monto impuesto';
COMMENT ON COLUMN keplersc.kdf3concept.c17 IS 'Porcentaje';
COMMENT ON COLUMN keplersc.kdf3concept.c16 IS 'Tipo factor: Tasa, cuota, excento';
COMMENT ON COLUMN keplersc.kdf3concept.c15 IS 'Clave impuesto';
COMMENT ON COLUMN keplersc.kdf3concept.c14 IS 'Precio total sin impuestos';
COMMENT ON COLUMN keplersc.kdf3concept.c13 IS 'Precio unitario sin impuestos';
COMMENT ON COLUMN keplersc.kdf3concept.c12 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3concept.c11 IS 'Clave producto o servicio SAT';
COMMENT ON COLUMN keplersc.kdf3concept.c10 IS 'Unidad medida';
COMMENT ON COLUMN keplersc.kdf3concept.c1 IS 'Sucursal';

