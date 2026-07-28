CREATE  TABLE keplersc.kdf3uso (
  c1 character varying NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3uso ADD CONSTRAINT pk_kdf3uso PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdf3uso IS 'Usos CFDI';
COMMENT ON COLUMN keplersc.kdf3uso.c6 IS 'Fin vigencia';
COMMENT ON COLUMN keplersc.kdf3uso.c5 IS 'Ini vigencia';
COMMENT ON COLUMN keplersc.kdf3uso.c4 IS 'Afecta persona moral';
COMMENT ON COLUMN keplersc.kdf3uso.c3 IS 'Afecta persona fisica';
COMMENT ON COLUMN keplersc.kdf3uso.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3uso.c1 IS 'Clave';

