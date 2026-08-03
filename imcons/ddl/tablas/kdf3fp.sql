CREATE  TABLE keplersc.kdf3fp (
  c1 character varying(2) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(8) NOT NULL DEFAULT ''::character varying,
  c4 character varying(8) NOT NULL DEFAULT ''::character varying,
  c5 character varying(8) NOT NULL DEFAULT ''::character varying,
  c6 character varying(8) NOT NULL DEFAULT ''::character varying,
  c7 character varying(30) NOT NULL DEFAULT ''::character varying,
  c8 character varying(8) NOT NULL DEFAULT ''::character varying,
  c9 character varying(8) NOT NULL DEFAULT ''::character varying,
  c10 character varying(30) NOT NULL DEFAULT ''::character varying,
  c11 character varying(8) NOT NULL DEFAULT ''::character varying,
  c12 character varying(80) NOT NULL DEFAULT ''::character varying,
  c13 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c14 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdf3fp ON keplersc.kdf3fp USING btree (c1) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdf3fp.c9 IS 'Cuenta Beneficiario';
COMMENT ON COLUMN keplersc.kdf3fp.c8 IS 'RFC Emisor';
COMMENT ON COLUMN keplersc.kdf3fp.c7 IS 'Patron';
COMMENT ON COLUMN keplersc.kdf3fp.c6 IS 'Cuenta Ordenante';
COMMENT ON COLUMN keplersc.kdf3fp.c5 IS 'RFC del Emisor';
COMMENT ON COLUMN keplersc.kdf3fp.c4 IS 'Número Operación';
COMMENT ON COLUMN keplersc.kdf3fp.c3 IS 'Bancarizado';
COMMENT ON COLUMN keplersc.kdf3fp.c2 IS 'Descripción';
COMMENT ON COLUMN keplersc.kdf3fp.c14 IS 'Fecha Fin Vigencia';
COMMENT ON COLUMN keplersc.kdf3fp.c13 IS 'Fecha Inicio Vigencia';
COMMENT ON COLUMN keplersc.kdf3fp.c12 IS 'Nombre Banco Emisor en caso de Extranjero';
COMMENT ON COLUMN keplersc.kdf3fp.c11 IS 'Tipo Cedena de Pago';
COMMENT ON COLUMN keplersc.kdf3fp.c10 IS 'Patron Cuenta Beneficiaria';
COMMENT ON COLUMN keplersc.kdf3fp.c1 IS 'Forma Pago';

