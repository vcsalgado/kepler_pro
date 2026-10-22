CREATE  TABLE keplersc.kdspaq_posxref (
  marca character varying(5) NOT NULL DEFAULT ''::character varying,
  modelo character varying(10) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  paquete character varying(5) NOT NULL DEFAULT ''::character varying,
  refaccion character varying(20) NOT NULL DEFAULT ''::character varying,
  posible_refacc character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdspaq_posxref_idx ON keplersc.kdspaq_posxref USING btree (marca, modelo, anio, paquete, refaccion, posible_refacc) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdspaq_posxref.refaccion IS 'Refaccion';
COMMENT ON COLUMN keplersc.kdspaq_posxref.posible_refacc IS 'Posible refacccion a utilizar en lugar de la refacc del paquete';
COMMENT ON COLUMN keplersc.kdspaq_posxref.paquete IS 'Paquete';
COMMENT ON COLUMN keplersc.kdspaq_posxref.modelo IS 'Modelo';
COMMENT ON COLUMN keplersc.kdspaq_posxref.marca IS 'Marca';
COMMENT ON COLUMN keplersc.kdspaq_posxref.anio IS 'Anio';

