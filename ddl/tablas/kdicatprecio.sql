CREATE  TABLE keplersc.kdicatprecio (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 numeric(6,2) NOT NULL DEFAULT 0,
  c5 numeric(6,2) NOT NULL DEFAULT 0,
  c6 numeric NOT NULL DEFAULT 0,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdicatprecio ADD CONSTRAINT pk_kdicatprecio PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdicatprecio.c7 IS 'Comisionable';
COMMENT ON COLUMN keplersc.kdicatprecio.c6 IS 'Catalogo a Utilizar';
COMMENT ON COLUMN keplersc.kdicatprecio.c5 IS 'IVA';
COMMENT ON COLUMN keplersc.kdicatprecio.c4 IS 'Utilidad Base';
COMMENT ON COLUMN keplersc.kdicatprecio.c3 IS 'Metodo de Calculo';
COMMENT ON COLUMN keplersc.kdicatprecio.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdicatprecio.c1 IS 'Clave';

