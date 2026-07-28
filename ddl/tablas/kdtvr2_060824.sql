CREATE  TABLE keplersc.kdtvr2_060824 (
  c1 character varying(15) NOT NULL,
  c2 character varying(15) NULL,
  c3 character varying(20) NULL,
  c4 character varying(2) NULL,
  c5 character varying(1) NULL,
  c6 numeric(15,2) NULL,
  c7 numeric(15,2) NULL,
  c8 numeric(15,2) NULL,
  c9 numeric NULL,
  c10 numeric(8,2) NULL,
  c11 character varying(2) NULL,
  c12 character varying(5) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtvr2_060824 ADD CONSTRAINT kdtvr2_pk PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdtvr2_060824.c8 IS 'distribuidor_precio_publico';
COMMENT ON COLUMN keplersc.kdtvr2_060824.c7 IS 'distribuidor_precio_mayoreo';
COMMENT ON COLUMN keplersc.kdtvr2_060824.c6 IS 'distribuidor_costo';

