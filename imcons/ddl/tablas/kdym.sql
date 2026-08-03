CREATE  TABLE keplersc.kdym (
  c1 character varying(4) NOT NULL DEFAULT ''::character varying,
  c2 character varying(1) NOT NULL DEFAULT ''::character varying,
  c3 character varying(1) NOT NULL DEFAULT ''::character varying,
  c4 character varying(1) NOT NULL DEFAULT ''::character varying,
  c5 character varying(1) NOT NULL DEFAULT ''::character varying,
  c6 character varying(1) NOT NULL DEFAULT ''::character varying,
  c7 character varying(1) NOT NULL DEFAULT ''::character varying,
  c8 character varying(1) NOT NULL DEFAULT ''::character varying,
  c9 character varying(1) NOT NULL DEFAULT ''::character varying,
  c10 character varying(1) NOT NULL DEFAULT ''::character varying,
  c11 character varying(1) NOT NULL DEFAULT ''::character varying,
  c12 character varying(1) NOT NULL DEFAULT ''::character varying,
  c13 character varying(1) NOT NULL DEFAULT ''::character varying,
  c14 character varying(1) NOT NULL DEFAULT ''::character varying,
  c15 character varying(1) NOT NULL DEFAULT ''::character varying,
  c16 character varying(1) NOT NULL DEFAULT ''::character varying,
  c17 character varying(1) NOT NULL DEFAULT ''::character varying,
  c18 character varying(1) NOT NULL DEFAULT ''::character varying,
  c19 character varying(1) NOT NULL DEFAULT ''::character varying,
  c20 character varying(1) NOT NULL DEFAULT ''::character varying,
  c21 character varying(1) NOT NULL DEFAULT ''::character varying
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS pk_kdym ON keplersc.kdym USING btree (c1) TABLESPACE pg_default;
COMMENT ON TABLE keplersc.kdym IS 'Anio Mes Config';
COMMENT ON COLUMN keplersc.kdym.c21 IS 'Dic';
COMMENT ON COLUMN keplersc.kdym.c20 IS 'Nov';
COMMENT ON COLUMN keplersc.kdym.c19 IS 'Oct';
COMMENT ON COLUMN keplersc.kdym.c18 IS 'Sep';
COMMENT ON COLUMN keplersc.kdym.c17 IS 'Ago';
COMMENT ON COLUMN keplersc.kdym.c16 IS 'Jul';
COMMENT ON COLUMN keplersc.kdym.c15 IS 'Jun';
COMMENT ON COLUMN keplersc.kdym.c14 IS 'May';
COMMENT ON COLUMN keplersc.kdym.c13 IS 'Abr';
COMMENT ON COLUMN keplersc.kdym.c12 IS 'Mar';
COMMENT ON COLUMN keplersc.kdym.c11 IS 'Feb';
COMMENT ON COLUMN keplersc.kdym.c10 IS 'Ene';
COMMENT ON COLUMN keplersc.kdym.c1 IS 'anio';

