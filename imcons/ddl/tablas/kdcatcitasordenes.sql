CREATE  TABLE keplersc.kdcatcitasordenes (
  c1 character varying NOT NULL,
  c2 character varying NOT NULL
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdcatcitasordenes IS 'Citas';
COMMENT ON COLUMN keplersc.kdcatcitasordenes.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdcatcitasordenes.c1 IS 'Tipo Cita/Orden';

