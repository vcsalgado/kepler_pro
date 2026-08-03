CREATE  TABLE keplersc.kdf3motivocancel (
  cve_motivo character varying(2) NOT NULL,
  descripcion character varying(100) NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdf3motivocancel IS 'Motivos de cancelacion de cfdi';
COMMENT ON COLUMN keplersc.kdf3motivocancel.descripcion IS 'Descripcion motivo de cancelacion';
COMMENT ON COLUMN keplersc.kdf3motivocancel.cve_motivo IS 'Clave motivo de cancelacion';

