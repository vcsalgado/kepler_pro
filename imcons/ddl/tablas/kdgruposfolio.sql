CREATE  TABLE keplersc.kdgruposfolio (
  c1 character varying(7) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0,
  c4 character varying(30) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdgruposfolio ADD CONSTRAINT pk_kdgruposfolio PRIMARY KEY (c1, c2);
COMMENT ON COLUMN keplersc.kdgruposfolio.c4 IS 'Descripcion';
COMMENT ON COLUMN keplersc.kdgruposfolio.c3 IS 'Folio Siguiente';
COMMENT ON COLUMN keplersc.kdgruposfolio.c2 IS 'Grupo';
COMMENT ON COLUMN keplersc.kdgruposfolio.c1 IS 'Sucursal';

