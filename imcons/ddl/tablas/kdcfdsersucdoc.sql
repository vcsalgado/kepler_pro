CREATE  TABLE keplersc.kdcfdsersucdoc (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 numeric NOT NULL DEFAULT 0,
  c5 numeric NOT NULL DEFAULT 0,
  c6 character varying(2) NOT NULL DEFAULT ''::character varying,
  c7 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdcfdsersucdoc ADD CONSTRAINT pk_kdcfdsersucdoc PRIMARY KEY (c1, c2, c3, c4, c5);
COMMENT ON TABLE keplersc.kdcfdsersucdoc IS 'CFD Serie Sucursal';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c7 IS 'Descripcion del documento';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c6 IS 'Serie';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c5 IS 'Tipo';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c4 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c3 IS 'Naturaleza';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c2 IS 'General';
COMMENT ON COLUMN keplersc.kdcfdsersucdoc.c1 IS 'Sucursal';

