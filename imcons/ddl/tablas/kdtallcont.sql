CREATE  TABLE keplersc.kdtallcont (
  c1 character varying(1) NOT NULL DEFAULT ''::character varying,
  c2 character varying(2) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(16) NOT NULL DEFAULT ''::character varying,
  c6 character varying(16) NOT NULL DEFAULT ''::character varying,
  c7 character varying(16) NOT NULL DEFAULT ''::character varying,
  c8 character varying(16) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(16) NOT NULL DEFAULT ''::character varying,
  c11 character varying(16) NOT NULL DEFAULT ''::character varying,
  c12 character varying(16) NOT NULL DEFAULT ''::character varying,
  c13 character varying(16) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(16) NOT NULL DEFAULT ''::character varying,
  c16 character varying(16) NOT NULL DEFAULT ''::character varying,
  c17 character varying(16) NOT NULL DEFAULT ''::character varying,
  c18 character varying(16) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtallcont ADD CONSTRAINT pk_kdtallcont PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdtallcont IS 'cuentas contables de tipos de ordenes';
COMMENT ON COLUMN keplersc.kdtallcont.c8 IS 'Ventas Varios';
COMMENT ON COLUMN keplersc.kdtallcont.c7 IS 'Ventas TOTs';
COMMENT ON COLUMN keplersc.kdtallcont.c6 IS 'Ventas Refacciones';
COMMENT ON COLUMN keplersc.kdtallcont.c5 IS 'Ventas M. Obra';
COMMENT ON COLUMN keplersc.kdtallcont.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdtallcont.c2 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdtallcont.c18 IS 'Puente Varios';
COMMENT ON COLUMN keplersc.kdtallcont.c17 IS 'Puente TOTs';
COMMENT ON COLUMN keplersc.kdtallcont.c16 IS 'Inventario Refacciones';
COMMENT ON COLUMN keplersc.kdtallcont.c15 IS 'Puente M. Obra';
COMMENT ON COLUMN keplersc.kdtallcont.c13 IS 'Costo Varios';
COMMENT ON COLUMN keplersc.kdtallcont.c12 IS 'Costo TOTs';
COMMENT ON COLUMN keplersc.kdtallcont.c11 IS 'Costo Refacciones';
COMMENT ON COLUMN keplersc.kdtallcont.c10 IS 'Costo M. Obra';
COMMENT ON COLUMN keplersc.kdtallcont.c1 IS 'Tipo de Orden';

