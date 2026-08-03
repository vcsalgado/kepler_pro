CREATE  TABLE keplersc.kdmodelos (
  c1 character varying(5) NOT NULL DEFAULT ''::character varying,
  c2 character varying(10) NOT NULL DEFAULT ''::character varying,
  c3 character varying(40) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(20) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
ALTER TABLE ONLY keplersc.kdmodelos ADD CONSTRAINT pk_kdmodelos PRIMARY KEY (c1, c2);
CREATE INDEX IF NOT EXISTS sindkdmodelos02 ON keplersc.kdmodelos USING btree (c2, c1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS sindkdmodelos03 ON keplersc.kdmodelos USING btree (c1, c2, c4) TABLESPACE pg_default;
COMMENT ON COLUMN keplersc.kdmodelos.c5 IS 'Equivalencia W32';
COMMENT ON COLUMN keplersc.kdmodelos.c4 IS 'Tipo Vehi A=Automovil C=Camion';
COMMENT ON COLUMN keplersc.kdmodelos.c3 IS 'Modelo';
COMMENT ON COLUMN keplersc.kdmodelos.c2 IS 'Clave';
COMMENT ON COLUMN keplersc.kdmodelos.c1 IS 'Marca';

