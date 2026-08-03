CREATE  TABLE keplersc.kdsubestatuscte (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsubestatuscte ADD CONSTRAINT kdsubestatuscte_pk PRIMARY KEY (c2, c1);
COMMENT ON TABLE keplersc.kdsubestatuscte IS 'Catalogo subestatus de cliente';
COMMENT ON COLUMN keplersc.kdsubestatuscte.c3 IS 'Descripcion subcondicion';
COMMENT ON COLUMN keplersc.kdsubestatuscte.c2 IS 'Clave condicion';
COMMENT ON COLUMN keplersc.kdsubestatuscte.c1 IS 'Clave subcondicion';

