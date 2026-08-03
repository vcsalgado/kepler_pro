CREATE  TABLE keplersc.kdgconf (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 numeric NOT NULL DEFAULT 0,
  c9 numeric NOT NULL DEFAULT 0,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 numeric NOT NULL DEFAULT 0,
  c13 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgconf ADD CONSTRAINT pk_kdgconf PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdgconf IS 'Configuracion compras';
COMMENT ON COLUMN keplersc.kdgconf.c9 IS 'Tpo';
COMMENT ON COLUMN keplersc.kdgconf.c8 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdgconf.c7 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgconf.c6 IS 'Genero Compra';
COMMENT ON COLUMN keplersc.kdgconf.c5 IS 'Tpo';
COMMENT ON COLUMN keplersc.kdgconf.c4 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdgconf.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgconf.c2 IS 'Genero Orden de Compra';
COMMENT ON COLUMN keplersc.kdgconf.c13 IS 'Tpo';
COMMENT ON COLUMN keplersc.kdgconf.c12 IS 'Gpo';
COMMENT ON COLUMN keplersc.kdgconf.c11 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdgconf.c10 IS 'Genero Cheques';
COMMENT ON COLUMN keplersc.kdgconf.c1 IS 'Indice';

