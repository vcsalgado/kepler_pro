CREATE  TABLE keplersc.kdlealtadheader (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(10) NOT NULL DEFAULT ''::character varying,
  c4 numeric(40,5) NOT NULL DEFAULT 0,
  c5 numeric(40,5) NOT NULL DEFAULT 0,
  c6 numeric(40,5) NOT NULL DEFAULT 0,
  c7 numeric(40,5) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdlealtadheader ADD CONSTRAINT pk_kdlealtadheader PRIMARY KEY (c1, c2, c3);
COMMENT ON COLUMN keplersc.kdlealtadheader.c7 IS 'Descuento Varios';
COMMENT ON COLUMN keplersc.kdlealtadheader.c6 IS 'Descuento TOTs';
COMMENT ON COLUMN keplersc.kdlealtadheader.c5 IS 'Descuento Refacciones';
COMMENT ON COLUMN keplersc.kdlealtadheader.c4 IS 'Descuento Mano de Obra';
COMMENT ON COLUMN keplersc.kdlealtadheader.c3 IS 'Orden';
COMMENT ON COLUMN keplersc.kdlealtadheader.c2 IS 'Tipo Orden';
COMMENT ON COLUMN keplersc.kdlealtadheader.c1 IS 'Sucursal';

