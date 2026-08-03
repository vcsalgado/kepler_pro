CREATE  TABLE keplersc.ifz_sofia_razon_cancelacion (
  codigo_cancelacion character varying(1) NOT NULL DEFAULT ''::character varying,
  razon_cancelacion character varying(100) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.ifz_sofia_razon_cancelacion ADD CONSTRAINT ifz_sofia_razon_cancelacion_pk PRIMARY KEY (codigo_cancelacion);
COMMENT ON TABLE keplersc.ifz_sofia_razon_cancelacion IS 'Catalogo de razones de cancelacion';
COMMENT ON COLUMN keplersc.ifz_sofia_razon_cancelacion.razon_cancelacion IS 'Descripcion de la razon en cancelacion de factura';
COMMENT ON COLUMN keplersc.ifz_sofia_razon_cancelacion.codigo_cancelacion IS 'Codigo de la razon en cancelacion de factura';

