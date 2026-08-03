CREATE  TABLE keplersc.kdordsint (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(5) NOT NULL DEFAULT ''::character varying,
  c7 character varying(5) NOT NULL DEFAULT ''::character varying,
  c8 character varying NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdordsint ADD CONSTRAINT pk_kdordsint PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdordsint IS 'Ordenes Sintomas';
COMMENT ON COLUMN keplersc.kdordsint.c8 IS 'Comentarios';
COMMENT ON COLUMN keplersc.kdordsint.c7 IS 'Valor Sintoma';
COMMENT ON COLUMN keplersc.kdordsint.c6 IS 'Clave del Sintoma';
COMMENT ON COLUMN keplersc.kdordsint.c5 IS 'Partida';
COMMENT ON COLUMN keplersc.kdordsint.c4 IS 'Punto de la Orden';
COMMENT ON COLUMN keplersc.kdordsint.c3 IS 'Folio de la Orden';
COMMENT ON COLUMN keplersc.kdordsint.c2 IS 'Tipo de Orden';
COMMENT ON COLUMN keplersc.kdordsint.c1 IS 'Sucursal';

