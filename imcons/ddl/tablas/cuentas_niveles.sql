CREATE  TABLE keplersc.cuentas_niveles (
  anio character varying NOT NULL,
  cuenta character varying NOT NULL,
  cuenta_padre character varying NULL,
  nivel integer NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.cuentas_niveles ADD CONSTRAINT cuentas_niveles_pkey PRIMARY KEY (anio, cuenta);

