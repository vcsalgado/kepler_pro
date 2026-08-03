CREATE  TABLE keplersc.kdyearcode (
  c1 character varying(2) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(4) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdyearcode ADD CONSTRAINT pk_kdyearcode PRIMARY KEY (c1);
COMMENT ON TABLE keplersc.kdyearcode IS 'Cat Codigo Anio placas';
COMMENT ON COLUMN keplersc.kdyearcode.c3 IS 'Anio';
COMMENT ON COLUMN keplersc.kdyearcode.c2 IS 'Codigo Anio';
COMMENT ON COLUMN keplersc.kdyearcode.c1 IS 'Id Codigo Anio';

