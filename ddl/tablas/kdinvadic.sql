CREATE  TABLE keplersc.kdinvadic (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 numeric(15,2) NOT NULL DEFAULT 0,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(25) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdinvadic ADD CONSTRAINT pk_kdinvadic PRIMARY KEY (c1, c2);
COMMENT ON COLUMN keplersc.kdinvadic.c6 IS 'Accesorios';
COMMENT ON COLUMN keplersc.kdinvadic.c5 IS '0=No 10=Si';
COMMENT ON COLUMN keplersc.kdinvadic.c4 IS 'Asesor';
COMMENT ON COLUMN keplersc.kdinvadic.c3 IS 'Apartado';
COMMENT ON COLUMN keplersc.kdinvadic.c2 IS 'Inventario';
COMMENT ON COLUMN keplersc.kdinvadic.c1 IS 'Sucursal';

