CREATE  TABLE keplersc.kdadvariable (
  c1 character varying(10) NOT NULL DEFAULT ''::character varying,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 character varying(50) NOT NULL DEFAULT ''::character varying,
  c4 character varying(50) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdadvariable ADD CONSTRAINT pk_kdadvariable PRIMARY KEY (c1, c2, c3);
COMMENT ON TABLE keplersc.kdadvariable IS 'Adendas Segemento Variables';
COMMENT ON COLUMN keplersc.kdadvariable.c4 IS 'Valor default';
COMMENT ON COLUMN keplersc.kdadvariable.c3 IS 'Clave variable';
COMMENT ON COLUMN keplersc.kdadvariable.c2 IS 'Clave segmento';
COMMENT ON COLUMN keplersc.kdadvariable.c1 IS 'Clave adenda';

