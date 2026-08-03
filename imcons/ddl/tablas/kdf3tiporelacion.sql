CREATE  TABLE keplersc.kdf3tiporelacion (
  tipo_relacion character varying(3) NOT NULL,
  descripcion character varying(100) NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdf3tiporelacion IS 'Tipo de relacion con otro cfdi';
COMMENT ON COLUMN keplersc.kdf3tiporelacion.tipo_relacion IS 'Clave de tipo relacion';
COMMENT ON COLUMN keplersc.kdf3tiporelacion.descripcion IS 'Descripcion de la relacion';

