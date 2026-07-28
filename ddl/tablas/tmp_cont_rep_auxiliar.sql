CREATE  TABLE keplersc.tmp_cont_rep_auxiliar (
  cuenta character varying(20) NULL,
  desc_cuenta character varying(40) NULL,
  tipo_poliza character varying(1) NULL,
  poliza numeric NULL,
  fecha_poliza timestamp without time zone NULL,
  sucursal character varying(7) NULL,
  documento character varying(25) NULL,
  desc_documento character varying(35) NULL,
  usuario character varying(23) NULL,
  desc_poliza character varying(40) NULL,
  cargo numeric(15,2) NULL,
  abono numeric(15,2) NULL,
  saldo numeric(15,2) NULL,
  saldo_inicial numeric(15,2) NULL,
  id_consulta uuid NOT NULL,
  fecha_ejecucion timestamp without time zone NOT NULL,
  orden numeric NOT NULL,
  referencia character varying(40) NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.tmp_cont_rep_auxiliar ADD CONSTRAINT tmp_cont_rep_auxiliar_pk PRIMARY KEY (orden, fecha_ejecucion, id_consulta);

