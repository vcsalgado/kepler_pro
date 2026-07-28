CREATE  TABLE keplersc.kdasesorcc (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(5) NOT NULL DEFAULT ''::character varying,
  c9 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdasesorcc ADD CONSTRAINT pk_kdasesorcc PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdasesorcc IS 'Asesores Contact Center';
COMMENT ON COLUMN keplersc.kdasesorcc.c9 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdasesorcc.c8 IS 'Esquema';
COMMENT ON COLUMN keplersc.kdasesorcc.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdasesorcc.c1 IS 'Clave';

