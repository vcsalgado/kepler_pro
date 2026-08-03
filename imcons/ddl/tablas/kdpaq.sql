CREATE  TABLE keplersc.kdpaq (
  c1 character varying(18) NOT NULL DEFAULT ''::character varying,
  c2 character varying(60) NOT NULL DEFAULT ''::character varying,
  c3 character varying(60) NOT NULL DEFAULT ''::character varying,
  c4 character varying(60) NOT NULL DEFAULT ''::character varying,
  c5 character varying(60) NOT NULL DEFAULT ''::character varying,
  c6 character varying(60) NOT NULL DEFAULT ''::character varying,
  c7 character varying(60) NOT NULL DEFAULT ''::character varying,
  c8 character varying(60) NOT NULL DEFAULT ''::character varying,
  c9 character varying(60) NOT NULL DEFAULT ''::character varying,
  c10 character varying(60) NOT NULL DEFAULT ''::character varying,
  c11 character varying(60) NOT NULL DEFAULT ''::character varying,
  c12 character varying(60) NOT NULL DEFAULT ''::character varying,
  c13 character varying(60) NOT NULL DEFAULT ''::character varying,
  c14 character varying(60) NOT NULL DEFAULT ''::character varying,
  c15 character varying(60) NOT NULL DEFAULT ''::character varying,
  c16 character varying(60) NOT NULL DEFAULT ''::character varying,
  c17 character varying(60) NOT NULL DEFAULT ''::character varying,
  c18 character varying(60) NOT NULL DEFAULT ''::character varying,
  c19 character varying(60) NOT NULL DEFAULT ''::character varying,
  c20 character varying(60) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdpaq ADD CONSTRAINT pk_kdpaq PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdpaq IS 'Paquetes';
COMMENT ON COLUMN keplersc.kdpaq.c9 IS 'Horas a pagar al operario';
COMMENT ON COLUMN keplersc.kdpaq.c8 IS 'Varios';
COMMENT ON COLUMN keplersc.kdpaq.c7 IS 'Refacciones';
COMMENT ON COLUMN keplersc.kdpaq.c6 IS 'Mano de obra';
COMMENT ON COLUMN keplersc.kdpaq.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdpaq.c4 IS 'Clave paquete';
COMMENT ON COLUMN keplersc.kdpaq.c3 IS 'Anio Modelo';
COMMENT ON COLUMN keplersc.kdpaq.c2 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdpaq.c10 IS 'Precio paquete';
COMMENT ON COLUMN keplersc.kdpaq.c1 IS 'Marca';

