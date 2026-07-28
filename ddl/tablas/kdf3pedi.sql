CREATE  TABLE keplersc.kdf3pedi (
  c1 character varying(2) NOT NULL DEFAULT ''::character varying,
  c2 character varying(4) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT ''::character varying,
  c4 character varying(6) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c6 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c7 character varying(2) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3pedi ADD CONSTRAINT pk_kdf3pedi PRIMARY KEY (c7, c1, c2, c4);
COMMENT ON TABLE keplersc.kdf3pedi IS 'F3 Pedimento';
COMMENT ON COLUMN keplersc.kdf3pedi.c7 IS 'Ultimos 2 digitos anio';
COMMENT ON COLUMN keplersc.kdf3pedi.c6 IS 'Fin Vigencia';
COMMENT ON COLUMN keplersc.kdf3pedi.c5 IS 'Inicio Vigencia';
COMMENT ON COLUMN keplersc.kdf3pedi.c4 IS 'Cantidad';
COMMENT ON COLUMN keplersc.kdf3pedi.c3 IS 'Ejercicio';
COMMENT ON COLUMN keplersc.kdf3pedi.c2 IS 'Patente';
COMMENT ON COLUMN keplersc.kdf3pedi.c1 IS 'Clave aduana';

