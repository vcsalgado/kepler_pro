CREATE  TABLE keplersc.kdcatestadotmktaccion (
  clave character varying(5) NOT NULL,
  descripcion character varying NOT NULL
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcatestadotmktaccion ADD CONSTRAINT kdcatestadotmktaccion_pk PRIMARY KEY (clave);

