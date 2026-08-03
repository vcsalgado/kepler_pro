CREATE  TABLE keplersc.kdsercotraz (
  c1 character varying(5) NULL,
  c2 character varying(50) NULL
) TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS kdsercotraz_c1_idx ON keplersc.kdsercotraz USING btree (c1) TABLESPACE pg_default;

