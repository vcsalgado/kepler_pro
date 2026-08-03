CREATE  TABLE keplersc.kdconfgenref (
  c1 numeric NOT NULL DEFAULT 0,
  c2 character varying(50) NOT NULL DEFAULT ''::character varying,
  c3 numeric NOT NULL DEFAULT 0
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdconfgenref ADD CONSTRAINT pk_kdconfgenref PRIMARY KEY (c1);
COMMENT ON COLUMN keplersc.kdconfgenref.c3 IS 'Meses para considerar obsoleto';
COMMENT ON COLUMN keplersc.kdconfgenref.c2 IS 'Directorio de taller';
COMMENT ON COLUMN keplersc.kdconfgenref.c1 IS 'Consecutivo';

