CREATE  TABLE keplersc.kdcartall (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(70) NOT NULL DEFAULT ''::character varying,
  c3 numeric(15,2) NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcartall ADD CONSTRAINT pk_kdcartall PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdcartall IS 'Cargos Varios';
COMMENT ON COLUMN keplersc.kdcartall.c3 IS 'Importe del cargo sin IVA';
COMMENT ON COLUMN keplersc.kdcartall.c2 IS 'Descripcion del cargo';
COMMENT ON COLUMN keplersc.kdcartall.c1 IS 'Clave del Cargo';

