CREATE  TABLE keplersc.kdctflujo (
  c1 character varying(2) NOT NULL DEFAULT ''::character varying,
  c2 character varying(40) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdctflujo ADD CONSTRAINT pk_kdctflujo PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdctflujo IS 'Catalogo cuentas de Flujo';
COMMENT ON COLUMN keplersc.kdctflujo.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdctflujo.c1 IS 'Clave';

