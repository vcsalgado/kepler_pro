CREATE  TABLE keplersc.kdf3rf (
  c1 character varying(3) NOT NULL DEFAULT ''::character varying,
  c2 character varying(80) NOT NULL DEFAULT ''::character varying,
  c3 character varying(2) NOT NULL DEFAULT ''::character varying,
  c4 character varying(2) NOT NULL DEFAULT ''::character varying,
  c5 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3rf ADD CONSTRAINT pk_kdf3rf PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdf3rf IS 'Catalogo Regimen Fiscal';
COMMENT ON COLUMN keplersc.kdf3rf.c5 IS 'Inicio de vigencia';
COMMENT ON COLUMN keplersc.kdf3rf.c4 IS 'Persona Moral';
COMMENT ON COLUMN keplersc.kdf3rf.c3 IS 'Persona Fisica';
COMMENT ON COLUMN keplersc.kdf3rf.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3rf.c1 IS 'Clave del regimen fiscal';

