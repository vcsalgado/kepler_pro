CREATE  TABLE keplersc.ser_ra_objetos_valor (
  clave_objeto character varying(5) NOT NULL DEFAULT ''::character varying,
  descripcion character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ser_ra_objetos_valor ADD CONSTRAINT ser_ra_objetos_valor_pkey PRIMARY KEY (clave_objeto);
COMMENT ON TABLE keplersc.ser_ra_objetos_valor IS 'Objetos de valor Recepcion Activa';
COMMENT ON COLUMN keplersc.ser_ra_objetos_valor.descripcion IS 'Descripcion';
COMMENT ON COLUMN keplersc.ser_ra_objetos_valor.clave_objeto IS 'Clave Objeto';

