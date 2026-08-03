CREATE  TABLE keplersc.tmp_cont_saldos_finales (
  cuenta character varying NULL,
  desc_cuenta character varying NULL,
  nivel numeric NULL,
  saldo_inicial numeric(15,2) NOT NULL DEFAULT 0,
  saldo_ene numeric(15,2) NOT NULL DEFAULT 0,
  saldo_feb numeric(15,2) NOT NULL DEFAULT 0,
  saldo_mar numeric(15,2) NOT NULL DEFAULT 0,
  saldo_abr numeric(15,2) NOT NULL DEFAULT 0,
  saldo_may numeric(15,2) NOT NULL DEFAULT 0,
  saldo_jun numeric(15,2) NOT NULL DEFAULT 0,
  saldo_jul numeric(15,2) NOT NULL DEFAULT 0,
  saldo_ago numeric(15,2) NOT NULL DEFAULT 0,
  saldo_sep numeric(15,2) NOT NULL DEFAULT 0,
  saldo_oct numeric(15,2) NOT NULL DEFAULT 0,
  saldo_nov numeric(15,2) NOT NULL DEFAULT 0,
  saldo_dic numeric(15,2) NOT NULL DEFAULT 0,
  id_consulta uuid NOT NULL,
  fecha_ejecucion timestamp without time zone NOT NULL,
  orden numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.tmp_cont_saldos_finales ADD CONSTRAINT tmp_cont_saldos_finales_pk PRIMARY KEY (orden, fecha_ejecucion, id_consulta);
CREATE INDEX IF NOT EXISTS tmp_cont_saldos_finales_1_idx ON keplersc.tmp_cont_saldos_finales USING btree (cuenta) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_sep IS 'Saldo septiembre';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_oct IS 'Saldo octubre';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_nov IS 'Saldo novimebre';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_may IS 'Saldo mayo';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_mar IS 'Saldo marzo';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_jun IS 'Saldo junio';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_jul IS 'Saldo julio';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_inicial IS 'Saldo inicial';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_feb IS 'Saldo feberero';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_ene IS 'Saldo enero';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_dic IS 'Saldo diciembre';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_ago IS 'Saldo agosto';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.saldo_abr IS 'Saldo abril';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.orden IS 'Orden';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.nivel IS 'Nivel cuenta';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.id_consulta IS 'Identificador';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.fecha_ejecucion IS 'Fecha ejecución';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.desc_cuenta IS 'Descripción cuenta';
COMMENT ON COLUMN keplersc.tmp_cont_saldos_finales.cuenta IS 'Cuenta';

