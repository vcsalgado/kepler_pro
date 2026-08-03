CREATE  TABLE keplersc.kdsertipobebida (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsertipobebida IS 'Tipo de Bebida';
COMMENT ON COLUMN keplersc.kdsertipobebida.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdsertipobebida.c1 IS 'Clave';

