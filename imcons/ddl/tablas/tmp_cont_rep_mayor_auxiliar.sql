CREATE  TABLE keplersc.tmp_cont_rep_mayor_auxiliar (
  cuenta character varying(20) NOT NULL,
  descripcion character varying(60) NULL,
  grupo integer NULL,
  nombre_grupo character varying(40) NULL,
  nivel integer NULL,
  saldo_inicial numeric(15,2) NULL DEFAULT 0,
  cargos numeric(15,2) NULL,
  abonos numeric(15,2) NULL,
  saldo_final numeric(15,2) NULL,
  polizas xml NULL,
  id_job uuid NOT NULL,
  fecha_ejecucion timestamp without time zone NULL,
  orden integer NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.tmp_cont_rep_mayor_auxiliar ADD CONSTRAINT tmp_cont_rep_mayor_auxiliar_pk PRIMARY KEY (cuenta, id_job);

