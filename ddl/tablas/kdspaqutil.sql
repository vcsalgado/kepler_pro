CREATE  TABLE keplersc.kdspaqutil (
  marca character varying(5) NOT NULL DEFAULT ''::character varying,
  modelo character varying(10) NOT NULL DEFAULT ''::character varying,
  anio character varying(4) NOT NULL DEFAULT ''::character varying,
  paquete character varying(5) NOT NULL DEFAULT ''::character varying,
  refaccion character varying(20) NOT NULL DEFAULT ''::character varying,
  cantidad numeric(15,6) NOT NULL DEFAULT 0,
  duplicada character varying(1) NOT NULL DEFAULT ''::character varying,
  refacc_duplicada character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdspaqutil_idx ON keplersc.kdspaqutil USING btree (marca, modelo, anio, paquete, refaccion) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdspaqutil.refaccion IS 'Refaccion';
COMMENT ON COLUMN keplersc.kdspaqutil.refacc_duplicada IS 'Clave de refacccion con la que se esta duplicando';
COMMENT ON COLUMN keplersc.kdspaqutil.paquete IS 'Paquete';
COMMENT ON COLUMN keplersc.kdspaqutil.modelo IS 'Modelo';
COMMENT ON COLUMN keplersc.kdspaqutil.marca IS 'Marca';
COMMENT ON COLUMN keplersc.kdspaqutil.duplicada IS 'Duplicada 0-No duplicada 1-duplicada';
COMMENT ON COLUMN keplersc.kdspaqutil.cantidad IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdspaqutil.anio IS 'Anio';

