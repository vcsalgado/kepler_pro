CREATE  TABLE keplersc.kdesqasepaq (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 numeric(10,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdesqasepaq ADD CONSTRAINT pk_kdesqasepaq PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdesqasepaq IS 'Asesores esquema paquetes';
COMMENT ON COLUMN keplersc.kdesqasepaq.c2 IS 'Comision del paquete';
COMMENT ON COLUMN keplersc.kdesqasepaq.c1 IS 'Clave del paquete';

