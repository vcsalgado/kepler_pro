CREATE  TABLE keplersc.kdsercontpref (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdsercontpref IS 'Medio preferido de contacto';
COMMENT ON COLUMN keplersc.kdsercontpref.c2 IS 'Descripci n';
COMMENT ON COLUMN keplersc.kdsercontpref.c1 IS 'Clave';

