CREATE  TABLE keplersc.kdf3mp (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3mp ADD CONSTRAINT pk_kdf3mp PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdf3mp IS 'Metodos de pago';
COMMENT ON COLUMN keplersc.kdf3mp.c4 IS 'Vigencia fin';
COMMENT ON COLUMN keplersc.kdf3mp.c3 IS 'Vigencia ini';
COMMENT ON COLUMN keplersc.kdf3mp.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3mp.c1 IS 'Clave';

