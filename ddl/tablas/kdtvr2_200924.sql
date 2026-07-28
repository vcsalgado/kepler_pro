CREATE  TABLE keplersc.kdtvr2_200924 (
  c1 character varying(15) NULL,
  c2 character varying(15) NULL,
  c3 character varying(20) NULL,
  c4 character varying(2) NULL,
  c5 character varying(1) NULL,
  c6 numeric(15,2) NULL,
  c7 numeric(15,2) NULL,
  c8 numeric(15,2) NULL,
  c9 numeric NULL,
  c10 numeric(8,2) NULL,
  c11 character varying(2) NULL,
  c12 character varying(5) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdtvr2_c1_idx ON keplersc.kdtvr2_200924 USING btree (c1) TABLESPACE pg_default;

