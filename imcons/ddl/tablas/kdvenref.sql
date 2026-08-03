CREATE  TABLE keplersc.kdvenref (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(30) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(7) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdvenref ADD CONSTRAINT pk_kdvenref PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdvenref.c4 IS 'Sucursal';
COMMENT ON COLUMN keplersc.kdvenref.c2 IS 'Nombre';
COMMENT ON COLUMN keplersc.kdvenref.c1 IS 'Abreviatura';

