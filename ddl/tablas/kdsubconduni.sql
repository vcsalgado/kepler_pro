CREATE  TABLE keplersc.kdsubconduni (
  c1 numeric NOT NULL DEFAULT 0,
  c2 numeric NOT NULL DEFAULT 0,
  c3 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdsubconduni ADD CONSTRAINT kdsubconduni_pk PRIMARY KEY (c2, c1);
COMMENT ON TABLE keplersc.kdsubconduni IS 'Cat logo subcondicion de unidad';
COMMENT ON COLUMN keplersc.kdsubconduni.c3 IS 'Descripcion subcondicion';
COMMENT ON COLUMN keplersc.kdsubconduni.c2 IS 'Clave condicion';
COMMENT ON COLUMN keplersc.kdsubconduni.c1 IS 'Clave subcondicion';

