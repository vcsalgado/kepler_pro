CREATE  TABLE keplersc.kdb1 (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(30) NOT NULL DEFAULT ''::character varying,
  c4 character varying(5) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(13) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdb1 ADD CONSTRAINT pk_kdb1 PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdb1 IS 'Bancos Cuentas';
COMMENT ON COLUMN keplersc.kdb1.c5 IS 'No Cuenta Contabilidad';
COMMENT ON COLUMN keplersc.kdb1.c3 IS 'No Cuenta';
COMMENT ON COLUMN keplersc.kdb1.c2 IS 'Nombre Banco';
COMMENT ON COLUMN keplersc.kdb1.c1 IS 'Clave Banco';

