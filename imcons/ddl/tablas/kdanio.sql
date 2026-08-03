CREATE  TABLE keplersc.kdanio (
  c1 character varying(4) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdanio ADD CONSTRAINT pk_kdanio PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdanio IS 'Anios';
COMMENT ON COLUMN keplersc.kdanio.c2 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdanio.c1 IS 'Anio modelo';

