CREATE  TABLE keplersc.kdf3uni (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(50) NOT NULL DEFAULT ''::character varying,
  c4 character varying(200) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3uni ADD CONSTRAINT pk_kdf3uni PRIMARY KEY (c1, c2);
COMMENT ON TABLE keplersc.kdf3uni IS 'F3 Unidades';
COMMENT ON COLUMN keplersc.kdf3uni.c7 IS 'Simbolo';
COMMENT ON COLUMN keplersc.kdf3uni.c6 IS 'Fin vigencia';
COMMENT ON COLUMN keplersc.kdf3uni.c5 IS 'Inicion vigencia';
COMMENT ON COLUMN keplersc.kdf3uni.c4 IS 'Nota';
COMMENT ON COLUMN keplersc.kdf3uni.c3 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3uni.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdf3uni.c1 IS 'Clave unidad';

