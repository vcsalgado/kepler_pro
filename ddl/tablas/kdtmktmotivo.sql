CREATE  TABLE keplersc.kdtmktmotivo (
  motivo_id numeric NOT NULL,
  descripcion character varying NOT NULL,
  tipo character varying(5) NOT NULL DEFAULT 'NA'::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdtmktmotivo ADD CONSTRAINT kdtmktmotivo_pk PRIMARY KEY (motivo_id);
ALTER TABLE ONLY keplersc.kdtmktmotivo ADD CONSTRAINT kdtmktmotivo_fk FOREIGN KEY (tipo) REFERENCES keplersc.kdcattipotmktmotivo(clave) ON UPDATE RESTRICT ON DELETE RESTRICT;

COMMENT ON TABLE keplersc.kdtmktmotivo IS 'motivos de los contactos de tmkt';

