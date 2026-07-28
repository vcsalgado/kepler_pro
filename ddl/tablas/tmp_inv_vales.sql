CREATE  TABLE keplersc.tmp_inv_vales (
  col_suc character varying NOT NULL DEFAULT ''::character varying,
  col_inv character varying NOT NULL DEFAULT ''::character varying,
  col_serie character varying NOT NULL DEFAULT ''::character varying,
  col_desc character varying NOT NULL DEFAULT ''::character varying,
  col_anio character varying NOT NULL DEFAULT ''::character varying,
  col_vale_salida character varying NOT NULL DEFAULT ''::character varying,
  col_traspaso character varying NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS tmp_inv_vales_col_suc_idx ON keplersc.tmp_inv_vales USING btree (col_suc, col_inv) TABLESPACE pg_default;

