CREATE  TABLE keplersc.kdtvr6_200924 (
  c1 character varying(15) NULL,
  c2 character varying(15) NULL,
  c3 character varying(40) NULL,
  c4 character varying(1) NULL,
  c5 numeric NULL,
  c6 numeric NULL,
  c7 numeric NULL,
  c8 numeric NULL,
  c9 numeric NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdtvr6_c1_idx ON keplersc.kdtvr6_200924 USING btree (c1) TABLESPACE pg_default;

