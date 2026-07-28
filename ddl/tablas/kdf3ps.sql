CREATE  TABLE keplersc.kdf3ps (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(100) NOT NULL DEFAULT ''::character varying,
  c3 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c4 timestamp without time zone NOT NULL DEFAULT '1800-01-01 00:00:00'::timestamp without time zone,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying,
  c6 character varying(20) NOT NULL DEFAULT ''::character varying,
  c7 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdf3ps ADD CONSTRAINT pk_kdf3ps PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdf3ps IS 'Catalogo productos y/o servicios SAT';
COMMENT ON COLUMN keplersc.kdf3ps.c7 IS 'Complemento que debe incluir';
COMMENT ON COLUMN keplersc.kdf3ps.c6 IS 'Incluir IEPS';
COMMENT ON COLUMN keplersc.kdf3ps.c5 IS 'Incluir IVA';
COMMENT ON COLUMN keplersc.kdf3ps.c4 IS 'Fin vigencia';
COMMENT ON COLUMN keplersc.kdf3ps.c3 IS 'Inicio vigencia';
COMMENT ON COLUMN keplersc.kdf3ps.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdf3ps.c1 IS 'Clave';

