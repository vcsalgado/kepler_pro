CREATE  TABLE keplersc.ser_ra_relacion_ra_ov (
  id numeric NOT NULL DEFAULT nextval('keplersc.ser_ra_relacion_ra_ov_id_seq'::regclass),
  clave_ra character varying(5) NOT NULL DEFAULT ''::character varying,
  clave_obj character varying(5) NOT NULL DEFAULT ''::character varying,
  valor boolean NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ser_ra_relacion_ra_ov ADD CONSTRAINT ser_ra_relacion_ra_ov_pkey PRIMARY KEY (id);
COMMENT ON TABLE keplersc.ser_ra_relacion_ra_ov IS 'Relacion Recepcion Activa con Objetos Valor';
COMMENT ON COLUMN keplersc.ser_ra_relacion_ra_ov.valor IS 'Valor';
COMMENT ON COLUMN keplersc.ser_ra_relacion_ra_ov.id IS 'Identificador';
COMMENT ON COLUMN keplersc.ser_ra_relacion_ra_ov.clave_ra IS 'Clave recepcion activa';
COMMENT ON COLUMN keplersc.ser_ra_relacion_ra_ov.clave_obj IS 'Clave Objeto';

