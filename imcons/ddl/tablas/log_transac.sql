CREATE  TABLE keplersc.log_transac (
  tran_id character varying(12) NULL,
  usuario character varying(10) NULL,
  referencia character varying(10) NULL,
  fecha timestamp without time zone NULL DEFAULT CURRENT_TIMESTAMP,
  paso character varying(100) NULL,
  resultado boolean NULL,
  mensaje text NULL,
  tipo character varying(5) NULL
) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS log_transac_tran_id_idx ON keplersc.log_transac USING btree (tran_id, usuario, referencia, fecha) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.log_transac IS 'Bitacora de transacciones';
COMMENT ON COLUMN keplersc.log_transac.usuario IS 'Usuario';
COMMENT ON COLUMN keplersc.log_transac.tran_id IS 'Identificador de transaccion';
COMMENT ON COLUMN keplersc.log_transac.tipo IS 'Tipo de mensaje en log';
COMMENT ON COLUMN keplersc.log_transac.resultado IS 'Resultado';
COMMENT ON COLUMN keplersc.log_transac.referencia IS 'Referencia de transaccion';
COMMENT ON COLUMN keplersc.log_transac.paso IS 'Paso en la transaccion';
COMMENT ON COLUMN keplersc.log_transac.fecha IS 'fecha';

