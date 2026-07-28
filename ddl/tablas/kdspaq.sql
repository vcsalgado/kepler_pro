CREATE  TABLE keplersc.kdspaq (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(50) NOT NULL DEFAULT ''::character varying,
  c6 numeric(15,2) NOT NULL DEFAULT 0,
  c7 numeric(15,2) NOT NULL DEFAULT 0,
  c8 numeric(15,2) NOT NULL DEFAULT 0,
  c9 numeric(10,5) NOT NULL DEFAULT 0,
  c10 numeric(15,2) NOT NULL DEFAULT 0,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdspaq ADD CONSTRAINT pk_kdspaq PRIMARY KEY (c1, c2, c4);
COMMENT ON TABLE keplersc.kdspaq IS 'Catalogo de paquetes';
COMMENT ON COLUMN keplersc.kdspaq.c9 IS 'Horas a Pagar al Operario';
COMMENT ON COLUMN keplersc.kdspaq.c8 IS 'Varios';
COMMENT ON COLUMN keplersc.kdspaq.c7 IS 'Refacciones';
COMMENT ON COLUMN keplersc.kdspaq.c6 IS 'Mano de Obra';
COMMENT ON COLUMN keplersc.kdspaq.c5 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdspaq.c4 IS 'Clave paquete';
COMMENT ON COLUMN keplersc.kdspaq.c2 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdspaq.c11 IS 'Paquete de Garantía';
COMMENT ON COLUMN keplersc.kdspaq.c10 IS 'Precio Paquete';
COMMENT ON COLUMN keplersc.kdspaq.c1 IS 'Marca';

